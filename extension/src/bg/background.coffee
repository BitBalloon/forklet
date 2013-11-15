# A brutish parser for MHTML (http://www.ietf.org/rfc/rfc2557.txt)
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


injectPageSlurper = (tabId) ->
  chrome.tabs.executeScript(tabId, {file: "src/bg/pageslurper.js"})


window.fork = (tabId) ->
  # Don't try to slurp a page we're already slurping. No inception here!
  chrome.tabs.executeScript tabId, {code: "window.forkletActive"}, (result) ->
    return if result[0]

    # Get an MHTML blob with all the files in the page
    chrome.pageCapture.saveAsMHTML {tabId: tabId}, (blob) ->

      reader = new FileReader
      reader.onload = ->
        files = parseMHTML(reader.result)
        process = []
        done    = []

        # Get the full location of the tab we're slurping
        chrome.tabs.executeScript tabId, {code: '"" + document.location.protocol + "//" + document.location.hostname + (document.location.port ? ":" + document.location.port : "")'}, (result) ->

          host = result[0]
          for file in files
            continue unless file.contentType.match(/image/)
            unless file.location.indexOf(host) == 0
              process.push(file)

          # Inject the page slurper if we don't need to inline any images
          return injectPageSlurper(tabId) unless process.length

          # Inline all external images as data URIs
          for file in process
            code = '(function() { var els = document.querySelectorAll(\'img[src="' + file.location + '"]\'); var src = "data:' + file.contentType + ';base64,' + file.content.replace(/\n/mg, '\\n').replace(/\r/mg, '\\r') + '"; for (var i = 0; i<els.length; i++) { els[i].src = src }})()'
            chrome.tabs.executeScript tabId, {
              code: code
            }, (result) ->
              done.push(file)
              if done.length == process.length
                injectPageSlurper(tabId)

      reader.readAsBinaryString(blob)