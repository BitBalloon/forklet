parseMHTML = (mhtml) ->
  chunks = mhtml

  try
    boundaryStart = chunks.indexOf("boundary=")
    chunks = chunks.substring(boundaryStart)
    boundary = null
    chunks = chunks.replace /^boundary="([^"]+)"/, (_, str) ->
      boundary = str
      ""

    files = []

    #regexp = new RegExp(boundary + "\\nContent-Type: ([^\\n]+)\\nContent-Transfer-Encoding: ([^\\n]+)\\nContent-Location: ([^\\n]+)\\n\\n", "m")

    previousLength = chunks.length
    while chunks
      file = {}
      chunks = chunks.substring(chunks.indexOf(boundary) + boundary.length + 1)

      chunks = chunks.replace /Content-Type: ([^\n]+)\n/, (_, contentType) ->
        file.contentType = contentType.replace(/\s+$/m, '')
        ""
      chunks = chunks.replace /Content-Transfer-Encoding: ([^\n]+)\n/, (_, encoding) ->
        file.encoding = encoding.replace(/\s+$/m, '')
        ""
      chunks = chunks.replace /Content-Location: ([^\n]+)\n/, (_, location) ->
        file.location = location.replace(/\s+$/m, '')
        ""

      chunks = chunks.replace /^\s+/m, ""

      break if chunks == boundary + "--"

      nextBoundary = chunks.indexOf(boundary)
      file.content = chunks.substring(0, nextBoundary-3)
      files.push(file)
      chunks = chunks.substring(nextBoundary)
      break if chunks.indexOf(boundary + "--") == 0
      break if previousLength == chunks.length
      previousLength = chunks.length
  catch e
    console.log("Error parsing all the things: %o", e)

  files


chrome.browserAction.onClicked.addListener (tab) ->
  chrome.tabs.executeScript tab.id, {code: "window.forkletActive"}, (result) ->
    return if result[0]

    chrome.pageCapture.saveAsMHTML {tabId: tab.id}, (blob) ->

      reader = new FileReader
      reader.onload = ->
        files = parseMHTML(reader.result)
        process = []
        done    = []
        chrome.tabs.executeScript tab.id, {code: '"" + document.location.protocol + "//" + document.location.hostname + (document.location.port ? ":" + document.location.port : "")'}, (result) ->
          host = result[0]
          for file in files
            continue unless file.contentType.match(/image/)
            unless file.location.indexOf(host) == 0
              process.push(file)

          for file in process
            code = '(function() { var els = document.querySelectorAll(\'img[src="' + file.location + '"]\'); var src = "data:' + file.contentType + ';base64,' + file.content.replace(/\n/mg, '\\n').replace(/\r/mg, '\\r') + '"; for (var i = 0; i<els.length; i++) { els[i].src = src }})()'
            chrome.tabs.executeScript tab.id, {
              code: code
            }, (result) ->
              done.push(file)
              if done.length == process.length
                chrome.tabs.executeScript(tab.id, {file: "src/bg/pageslurper.js"})


      reader.readAsBinaryString(blob)