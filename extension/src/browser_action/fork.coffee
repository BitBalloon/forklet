console.log("Hello, world")
chrome.tabs.getCurrent (tab) ->
  console.log("Current tab %o", tab)
  chrome.pageCapture.saveAsMHTML {tabId: tab.id}, (allTheThings) ->
    console.log("We have all the things!")
    console.log(allTheThings)

# pageHTML = document.documentElement.innerHTML

# allPageScripts = document.querySelectorAll('script[src]')
# allPageStyles = document.querySelectorAll('link[rel="stylesheet"]')

# localElements = (elements, attr) ->
#   for element in allPageStyles when element.getAttribute(attr).match(/^(https?:)?\/\//)
#     element.getAttribute("href")

# localPageStyles  = localElements(allPageStyles, "href")
# localPageScripts = localElements(allPageScripts, "src")




# for ref in localPageStyles
#   oReq = new XMLHttpRequest()
#   oReq.onload = reqListener
#   oReq.open("get", ref, true)
#   oReq.send()


# filesInTheSite = [
#   "/index.html": sha1.hash(pageHTML)
#   "/css/style.css": "body { ... } "
# ]



# files = {
#   "/index.html": "1235354564345563534",
#   "/css/style.css": "t45424525252"
# }

# ["1235354564345563534", "t45424525252"]



