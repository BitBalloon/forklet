console.log("Hello")
chrome.browserAction.onClicked.addListener (tab) ->
  console.log("Hmm")
  chrome.tabs.executeScript tab.id, {code: "window.forkletActive"}, (result) ->
    console.log(result[0])
    return if result[0]

    chrome.tabs.executeScript(tab.id, {file: "src/bg/pageslurper.js"})