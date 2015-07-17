const {classes: Cc, interfaces: Ci, utils: Cu} = Components;
Cu.import("resource://gre/modules/Services.jsm");
Cu.import("resource://gre/modules/XPCOMUtils.jsm");

const EXPORTED_SYMBOLS = [];

var gForceExternalHandler = false;

XPCOMUtils.defineLazyServiceGetter(this, "extProtocolSvc",
    "@mozilla.org/uriloader/external-protocol-service;1", "nsIExternalProtocolService");

var documentObserver = {
  observe: function observe(subject, topic, data) {
    if (subject instanceof Ci.nsIDOMWindow && topic == 'content-document-global-created') {
      var doc = subject.document;
      doc.addEventListener("DOMContentLoaded", function(event) {
        event.target.removeEventListener("DOMContentLoaded", arguments.callee, false);
        // If the parent document is a local file, don't do anything
        // Links will just work
        if (doc.location.href.indexOf("file://") == 0) {
          return;
        }
        var links = event.target.getElementsByTagName("a");
        for (var i=0; i < links.length; i++) {
          var link = links[i];
          if (link.href.indexOf("file://") != 0) {
            continue;
          }
          link.addEventListener("click", function(link) {
            return function(event) {
              event.preventDefault();
              if (gForceExternalHandler) {
                extProtocolSvc.loadUrl(Services.io.newURI(link.href, null, null));
              } else {
                var win = Services.wm.getMostRecentWindow("navigator:browser");
                if (win) {
                  var target = "_self";
                  if (link.hasAttribute("target")) {
                    target = link.getAttribute("target");
                  }
                  // If we were told somewhere other than current (based on modifier keys), use it
                  var where = win.whereToOpenLink(event);
                  if (where != "current") {
                    win.openUILinkIn(link.href, where);
                    return;
                  }
                  switch (target) {
                    case "_blank":
                      win.openUILinkIn(link.href, "tab");
                      break;
                    case "_self":
                      link.ownerDocument.location = link.href;
                      break;
                    case "_parent":
                      link.ownerDocument.defaultView.parent.document.location = link.href;
                      break;
                    case "_top":
                      link.ownerDocument.defaultView.top.document.location = link.href;
                      break;
                    default:
                      // Attempt to find the iframe that this goes into
                      var iframes = doc.defaultView.parent.document.getElementsByName(target);
                      if (iframes.length > 0) {
                        iframes[0].contentDocument.location = link.href;
                      } else {
                        link.ownerDocument.location = link.href;
                      }
                      break;
                  }
                }
              }
            }
          }(link), false);
        }
      }, false);
    }
  }
}

var CAPSCheckLoadURI = {
  observe: function observe(subject, topic, data) {
    switch (topic) {
    case "final-ui-startup":
      Services.obs.removeObserver(CAPSCheckLoadURI, "final-ui-startup", false);
      // Don't do this check before Firefox 29
      if (Services.vc.compare(Services.appinfo.version, "29") <= 0) {
        return;
      }
      var defaultCheckLoadURIPolicy = false;
      try {
        if (Services.prefs.getCharPref("capability.policy.default.checkloaduri.enabled") == "allAccess") {
          defaultCheckLoadURIPolicy = true;
        }
      } catch (e) {}
      if (defaultCheckLoadURIPolicy == false) {
        return;
      }
      gForceExternalHandler = !extProtocolSvc.isExposedProtocol('file');
      Services.obs.addObserver(documentObserver, "content-document-global-created", false);
      break;
    case "quit-application":
      Services.obs.removeObserver(CAPSCheckLoadURI, "quit-application", false);
      Services.obs.removeObserver(documentObserver, 'content-document-global-created', false);
      break;
    }
  }
}

Services.obs.addObserver(CAPSCheckLoadURI, "final-ui-startup", false);
Services.obs.addObserver(CAPSCheckLoadURI, "quit-application", false);
