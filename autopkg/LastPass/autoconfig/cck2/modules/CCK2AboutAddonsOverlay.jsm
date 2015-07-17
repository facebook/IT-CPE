/* This file overlays about:addons. It does the following: */
/*   Workaround https://bugzilla.mozilla.org/show_bug.cgi?id=1132971 */
/*   Hide the "Install Add-on From File" menu if xpinstall.enabled is false */
/*   Hides the discover pane if xpinstall.enabled is false */
/*   Hides the add-on entry if specified in the CCK2 config */

const EXPORTED_SYMBOLS = [];

const {classes: Cc, interfaces: Ci, utils: Cu} = Components;

Cu.import("resource://gre/modules/Services.jsm");
Cu.import("resource://cck2/CCK2.jsm");

var observer = {
  observe: function observe(subject, topic, data) {
    switch (topic) {
      case "chrome-document-global-created":
        var win = subject.QueryInterface(Components.interfaces.nsIDOMWindow);
        win.addEventListener("load", function(event) {
          win.removeEventListener("load", arguments.callee, false);
          var doc = event.target;
          var url = doc.location.href.split("?")[0].split("#")[0];
          switch (url) {
            case "about:addons":
            case "chrome://mozapps/content/extensions/extensions.xul":
              var configs = CCK2.getConfigs();
              for (id in configs) {
                var config = configs[id];
                if (config && "extension" in config && config.extension.hide) {
                  win.addEventListener("ViewChanged", function() {
                    hide(doc.querySelector("richlistitem[value='" + config.extension.id + "']"));
                  } , false)
                  hide(doc.querySelector("richlistitem[value='" + config.extension.id + "']"));
                }
              }
              var showDiscoverPane = true;
              var xpinstallEnabled = true;
              try {
                xpinstallEnabled = Services.prefs.getBoolPref("xpinstall.enabled");
              } catch (e) {}
              try {
                showDiscoverPane = Services.prefs.getBoolPref("extensions.getAddons.showPane");
              } catch (e) {}
              if (!xpinstallEnabled || !showDiscoverPane) {
                // Work around Mozilla bug 1132971
                // Hide the discover pane if it is the selected pane
                if (E("view-port", doc) && E("view-port", doc).selectedIndex == 0) {
                  try {
                    win.gViewController.loadView("addons://list/extension");
                  } catch (ex) {
                    // This fails with Webconverger installed. Ignore it.
                  }
                }
              }
              if (!xpinstallEnabled) {
                // Hide the "Install Add-on From File" separator
                hide(E("utils-installFromFile-separator", doc));
                // Hide the "Install Add-on From File" menuitem
                hide(E("utils-installFromFile", doc));
              }
              break;
          }
        }, false);
        break;
    }
  }
}

Services.obs.addObserver(observer, "chrome-document-global-created", false);

function E(id, context) {
  var element = context.getElementById(id);
  return element;
}

function hide(element) {
  if (element) {
    element.setAttribute("hidden", "true");
  }
}
