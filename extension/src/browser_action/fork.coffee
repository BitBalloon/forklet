token        = null
clientId     = "078f2156c3d0199090910612185881a68eef7fa71fe47ef1cea6d6fc4fb76d56"
authHost     = "https://www.bitballoon.com"
resourceHost = "https://www.bitballoon.com/api/v1"
redirectURI  = "https://www.bitballoon.com/robots.txt"
# authHost     = "http://www.bitballoon.lo:9393"
# resourceHost = "http://www.bitballoon.lo:9393/api/v1"
endUserAuthorizationEndpoint = authHost + "/oauth/authorize"

tokenInUrl = ->
  match = document.location.hash.match(/access_token=(\w+)/);
  token = match && match[1]

tokenInLocalStorage = ->
  token = localStorage.getItem("forklettoken")

callForkInPopup = ->
  tab = localStorage.getItem("tabId")
  localStorage.removeItem("tabId")
  tabId = parseInt(tab, 10)
  chrome.tabs.update tabId, {active: true}, ->
    chrome.extension.getBackgroundPage().fork(tabId)
    closeWindow()

closeWindow = ->
  window.open('', '_self', '')
  window.close()

openAuthTab = ->
  chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->
    localStorage.setItem("tabId", tabs[0].id)
    authUrl = endUserAuthorizationEndpoint + "?response_type=token&client_id=" + clientId + "&redirect_uri=" + encodeURIComponent(redirectURI)
    chrome.tabs.create({url: authUrl})

fork = ->
  chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->
    setTimeout(closeWindow, 100)
    chrome.extension.getBackgroundPage().fork(tabs[0].id)

if tokenInUrl()
  localStorage.setItem("forklettoken", token)
  callForkInPopup()
else if tokenInLocalStorage()
  fork()
else
  openAuthTab()
