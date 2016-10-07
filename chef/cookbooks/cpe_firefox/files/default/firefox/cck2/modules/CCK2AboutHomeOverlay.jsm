/* This file overrides about:home. It does the following:
 *   Remove the sync button if Sync is disabled
 *   Remove the Addons button if Sync is disabled
 *   Remove the snippets if snippets are disabled
 */

const EXPORTED_SYMBOLS = [];

const {classes: Cc, interfaces: Ci, utils: Cu} = Components;

Cu.import("resource://gre/modules/Services.jsm");
Cu.import("resource://cck2/CCK2.jsm");

var configs = null;

var observer = {
  observe: function observe(subject, topic, data) {
    switch (topic) {
      case "content-document-global-created":
        var win = subject.QueryInterface(Components.interfaces.nsIDOMWindow);
        win.addEventListener("load", function(event) {
          win.removeEventListener("load", arguments.callee, false);
          var doc = event.target;
          var url = doc.location.href.split("?")[0].split("#")[0];
          switch (url) {
            case "about:home":
            case "chrome://browser/content/abouthome/aboutHome.xhtml":
              if (!configs) {
                configs = CCK2.getConfigs();
              }
              for (id in configs) {
                var config = configs[id];
                if (config.disableSync) {
                  remove(E("sync", doc));
                }
                if (config.disableAddonsManager) {
                  remove(E("addons", doc));
                }
                if (config.disableWebApps) {
                  remove(E("apps", doc));
                }
                if (config.removeSnippets) {
                  var snippets = E("snippets", doc);
                  if (snippets) {
                    snippets.style.display = "none";
                  }
                }
              }
              break;
          }
        }, false);
        break;
    }
  }
}
Services.obs.addObserver(observer, "content-document-global-created", false);

function E(id, context) {
  var element = context.getElementById(id);
  return element;
}

function remove(element) {
  if (element && element.parentNode)
    element.parentNode.removeChild(element);
}
