url = window.location.href
match = url.match(/#([^?]+)/)
params = match && match[1]

params += '&from=' + encodeURIComponent(url)
redirect = chrome.extension.getURL('src/browser_action/browser_action.html')
console.log("Injected - redirect to %o", redirect)
window.location = redirect + "#" + params