# if you checked "fancy-settings" in extensionizr.com, uncomment this lines

# var settings = new Store("settings", {
#     "sample_setting": "This is how you use Store.js to remember values"
# });

#example of using a message handler from the inject scripts
chrome.browserAction.onClicked.addListener (tab) ->
  alert "test"
  console.log "Click on %o", tab

  chrome.pageCapture.saveAsMHTML {tabId: tab.id}, (allTheThings) ->
    console.log("We have all the things!")
    console.log(allTheThings)
    reader = new FileReader
    reader.onload = (e) ->
      console.log("Die console, die:")
      console.log(e.target.result)
    reader.readAsBinaryString(allTheThings)



chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
  chrome.pageAction.show sender.tab.id
  sendResponse()
