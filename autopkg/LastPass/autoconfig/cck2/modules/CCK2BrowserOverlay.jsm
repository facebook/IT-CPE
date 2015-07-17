/* This file modifies the main browser window. It does the following:
 *   Goes through the hiddenUI list and hides any UI
 *
 */

const EXPORTED_SYMBOLS = [];

const {classes: Cc, interfaces: Ci, utils: Cu} = Components;

Cu.import("resource://gre/modules/Services.jsm");
Cu.import("resource:///modules/CustomizableUI.jsm");
Cu.import("resource://gre/modules/PrivateBrowsingUtils.jsm");
Cu.import("resource://cck2/CCK2.jsm");

var configs = null;

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
            case "chrome://browser/content/browser.xul":
              // Workaround https://bugzilla.mozilla.org/show_bug.cgi?id=1149617
              var origSetReportPhishingMenu = win.gSafeBrowsing.setReportPhishingMenu;
              win.gSafeBrowsing.setReportPhishingMenu = function() {
                try {
                  origSetReportPhishingMenu();
                } catch (e) {}
              }

              win.addEventListener("unload", function(event) {
                win.removeEventListener("unload", arguments.callee, false);
                var panelUIPopup = doc.getElementById("PanelUI-popup");
                if (panelUIPopup) {
                  E("PanelUI-popup", doc).removeEventListener("popupshowing", onPanelShowing, false);
                }
              });
              var panelUIPopup = doc.getElementById("PanelUI-popup");
              if (panelUIPopup) {
                E("PanelUI-popup", doc).addEventListener("popupshowing", onPanelShowing, false);
              }
              configs = CCK2.getConfigs();
              for (id in configs) {
                var config = configs[id];       
                var configs = CCK2.getConfigs();
                for (var id in configs) {
                  config = configs[id];
                  if (config.disablePrivateBrowsing &&
                      PrivateBrowsingUtils.isWindowPrivate(win)) {
                    win.setTimeout(function() {
                      Services.prompt.alert(win, "Private Browsing", "Private Browsing has been disabled by your administrator");
                      win.close();
                    }, 0, false);
                  }
                  if (config.disablePrivateBrowsing) {
                    disablePrivateBrowsing(doc);
                  }
                  if (config.disableSync) {
                    disableSync(doc);
                  }
              
                  if (config.disableAddonsManager) {
                    disableAddonsManager(doc);
                  }
                  if (config.removeDeveloperTools) {
                    Services.tm.mainThread.dispatch(function() {
                      removeDeveloperTools(doc);
                    }, Ci.nsIThread.DISPATCH_NORMAL);
                  }
                  if (config.disableErrorConsole) {
                    disableErrorConsole(doc);
                  }
                  if (config.disableFirefoxHealthReport) {
                    var healthReportMenu = doc.getElementById("healthReport");
                    if (healthReportMenu) {
                      healthReportMenu.parentNode.removeChild(healthReportMenu);
                    }
                  }
                  if (config.removeSafeModeMenu) {
                    hide(E("helpSafeMode", doc));
                  }
                  if (config.titlemodifier) {
                    doc.getElementById("main-window").setAttribute("titlemodifier", config.titlemodifier);
                  }
                  if (config.removeSetDesktopBackground) {
                    // Because this is on a context menu, we can't use "hidden"
                    if (E("context-setDesktopBackground", doc)) {
                      E("context-setDesktopBackground", doc).setAttribute("style", "display: none;");
                    }
                  }
                  if (config.disableWebApps) {
                    CustomizableUI.destroyWidget("web-apps-button");
                    hide(E("menu_openApps", doc));
                  }
                  if (config.disableHello) {
                    CustomizableUI.destroyWidget("loop-button");
                  }
                  if (config.disableSharePage) {
                    CustomizableUI.destroyWidget("social-share-button");
                    // Because these are on a context menu, we can't use "hidden"
                    if (E("context-sharelink", doc)) {
                      E("context-sharelink", doc).setAttribute("style", "display: none;");
                    }
                    if (E("context-shareselect", doc)) {
                      E("context-shareselect", doc).setAttribute("style", "display: none;");
                    }
                    if (E("context-shareimage", doc)) {
                      E("context-shareimage", doc).setAttribute("style", "display: none;");
                    }
                    if (E("context-sharevideo", doc)) {
                      E("context-sharevideo", doc).setAttribute("style", "display: none;");
                    }
                    if (E("context-sharepage", doc)) {
                      E("context-sharepage", doc).setAttribute("style", "display: none;");
                    }
                  }
                  if (config.disableForget) {
                    CustomizableUI.destroyWidget("panic-button");
                  }
                  if (config.hiddenUI) {
                    for (var i=0; i < config.hiddenUI.length; i++) {
                      var uiElements = doc.querySelectorAll(config.hiddenUI[i]);
                      // Don't use .hidden since it doesn't work sometimes
                      var style = doc.getElementById("cck2-hidden-style");
                      if (!style) {
                        style = doc.createElementNS("http://www.w3.org/1999/xhtml", "style");
                        style.setAttribute("id", "cck2-hidden-style");
                        style.setAttribute("type", "text/css");
                        doc.getElementById("main-window").appendChild(style);
                      }
                      style.textContent = style.textContent + config.hiddenUI[i] + "{display: none !important;}";
                      if (!uiElements || uiElements.length == 0) {
                        continue;
                      }
                      for (var j=0; j < uiElements.length; j++) {
                        var uiElement = uiElements[j];
                        if (uiElement.nodeName == "menuitem") {
                          uiElement.removeAttribute("key");
                          uiElement.removeAttribute("oncommand");
                          if (uiElement.hasAttribute("command")) {
                            var commandId = uiElement.getAttribute("command");
                            uiElement.removeAttribute("command");
                            var command = doc.getElementById(commandId);
                            command.removeAttribute("oncommand");
                            var keys = doc.querySelectorAll("key[command='" + commandId + "']")
                            for (var k=0; k < keys.length; k++) {
                              keys[k].removeAttribute("command");
                            }
                          }
                        }
                        // Horrible hack to work around the crappy Australis help menu
                        // Items on the menu always show up in the Australis menu, so we have to remove them.
                        if (uiElements[j].parentNode.id == "menu_HelpPopup") {
                          uiElements[j].parentNode.removeChild(uiElements[j]);
                        }
                      }
                    }
                  }
                  if (config.helpMenu) {
                    // We need to run this function on a delay, because we won't know
                    // if the about menu is hidden for mac until after it is run.
                    Services.tm.mainThread.dispatch(function() {
                      var helpMenuPopup = doc.getElementById("menu_HelpPopup");
                      var menuitem = doc.createElement("menuitem");
                      menuitem.setAttribute("label", config.helpMenu.label);
                      if ("accesskey" in config.helpMenu) {
                        menuitem.setAttribute("accesskey", config.helpMenu.accesskey);
                      }
                      menuitem.setAttribute("oncommand", "openUILink('" + config.helpMenu.url + "');");
                      menuitem.setAttribute("onclick", "checkForMiddleClick(this, event);");
                      if (!E("aboutName", doc) || E("aboutName", doc).hidden) {
                        // Mac
                        helpMenuPopup.appendChild(menuitem);
                      } else {
                        helpMenuPopup.insertBefore(menuitem, E("aboutName", doc));
                        helpMenuPopup.insertBefore(doc.createElement("menuseparator"),
                                                          E("aboutName", doc));
                      }
                    }, Ci.nsIThread.DISPATCH_NORMAL);
                  }
                  if (config.firstrun || config.upgrade) {
                    if (config.displayBookmarksToolbar || (config.bookmarks && config.bookmarks.toolbar)) {
                      CustomizableUI.setToolbarVisibility("PersonalToolbar", "true");         
                    }
                    if (config.displayMenuBar) {
                      CustomizableUI.setToolbarVisibility("toolbar-menubar", "true");         
                    }
                    config.firstrun = false;
                    config.upgrade = false;
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
Services.obs.addObserver(observer, "chrome-document-global-created", false);

function disableSync(doc) {
  var win = doc.defaultView;
  if (win.gSyncUI) {
    var mySyncUI = {
      init: function() {
        return;
      },
      initUI: function() {
        return;
      },
      updateUI: function() {
        hide(E("sync-setup-state", doc));
        hide(E("sync-syncnow-state", doc));
        hide(E("sync-setup", doc));
        hide(E("sync-syncnowitem", doc));
      }
    }
    win.gSyncUI = mySyncUI;
  }
  CustomizableUI.destroyWidget("sync-button");
  CustomizableUI.removeWidgetFromArea("sync-button");
  var toolbox = doc.getElementById("navigator-toolbox");
  if (toolbox && toolbox.palette) {
    element = toolbox.palette.querySelector("#sync-button");
    if (element) {
      element.parentNode.removeChild(element);
    }
  }
  hide(E("sync-setup-state", doc));
  hide(E("sync-syncnow-state", doc));
  hide(E("sync-setup", doc));
  hide(E("sync-syncnowitem", doc));
}

function disablePrivateBrowsing(doc) {
  disable(E("Tools:PrivateBrowsing", doc));
  hide(E("menu_newPrivateWindow", doc));
  // Because this is on a context menu, we can't use "hidden"
  if (E("context-openlinkprivate", doc))
    E("context-openlinkprivate", doc).setAttribute("style", "display: none;");
  CustomizableUI.destroyWidget("privatebrowsing-button")
}

function disableAddonsManager(doc) {
  hide(E("menu_openAddons", doc));
  disable(E("Tools:Addons", doc)); // Ctrl+Shift+A
  CustomizableUI.destroyWidget("add-ons-button")
}

function removeDeveloperTools(doc) {
  var win = doc.defaultView;
  hide(E("developer-button", doc));
  hide(E("webDeveloperMenu", doc));
  // Need to delay this because devtools is created dynamically
  win.setTimeout(function() {
    var devtoolsKeyset = doc.getElementById("devtoolsKeyset");
    if (devtoolsKeyset) {
      for (var i = 0; i < devtoolsKeyset.childNodes.length; i++) {
        devtoolsKeyset.childNodes[i].removeAttribute("command");
      }
    }
  }, 0);
  try {
    doc.getElementById("Tools:ResponsiveUI").removeAttribute("oncommand");
  } catch (e) {}
  try {
    doc.getElementById("Tools:Scratchpad").removeAttribute("oncommand");
  } catch (e) {}
  try {
    doc.getElementById("Tools:BrowserConsole").removeAttribute("oncommand");
  } catch (e) {}
  try {
    doc.getElementById("Tools:BrowserToolbox").removeAttribute("oncommand");
  } catch (e) {}
  try {
    doc.getElementById("Tools:DevAppsMgr").removeAttribute("oncommand");
  } catch (e) {}
  try {
    doc.getElementById("Tools:DevToolbar").removeAttribute("oncommand");
  } catch (e) {}
  try {
    doc.getElementById("Tools:DevToolbox").removeAttribute("oncommand");
  } catch (e) {}
  try {
    doc.getElementById("Tools:DevToolbarFocus").removeAttribute("oncommand");
  } catch (e) {}
  CustomizableUI.destroyWidget("developer-button")
}

function disableErrorConsole(doc) {
  doc.getElementById("Tools:ErrorConsole").removeAttribute("oncommand");
}

function onPanelShowing(event) {
  var configs = CCK2.getConfigs();
  for (id in configs) {
    var config = configs[id];       
    if (config.disableSync) {
      hide(E("PanelUI-fxa-status", event.target.ownerDocument));
    }
  }
}

function E(id, context) {
  var element = context.getElementById(id);
  return element;
}

function hide(element) {
  if (element) {
    element.setAttribute("hidden", "true");
  }
}

function disable(element) {
  if (element) {
    element.disabled = true;
    element.setAttribute("disabled", "true");
  }
}
