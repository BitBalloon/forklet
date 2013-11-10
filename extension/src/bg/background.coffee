# if you checked "fancy-settings" in extensionizr.com, uncomment this lines

#example of using a message handler from the inject scripts
chrome.browserAction.onClicked.addListener (tab) ->
  chrome.tabs.executeScript tab.id, {code: "window.forkletActive"}, (result) ->
    return if result[0]

    chrome.tabs.executeScript(tab.id, {file: "src/bg/pageslurper.js"})