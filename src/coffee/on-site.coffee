uiEl               = null
highlightContainer = null
highlightElements  = {}
contentBeforeEdit  = null
currentElement     = null
changes            = {}
files              = null
readyToSave        = false
imagesToSave       = []


removeScriptTagFromDom = ->
  target = document.documentElement
  while target.childNodes.length and target.lastChild.nodeType is 1 # find last HTMLElement child node
    target = target.lastChild;
  # target is now the script element
  target.parentElement.removeChild(target)


removeScriptTagFromDom()


authHost     = "https://www.bitballoon.com"
resourceHost = "https://www.bitballoon.com/api/v1"
# authHost     = "http://www.bitballoon.lo:9393"
# resourceHost = "http://www.bitballoon.lo:9393/api/v1"
endUserAuthorizationEndpoint = authHost + "/oauth/authorize"


extractToken = (hash) ->
  match = hash.match(/access_token=(\w+)/);
  match && match[1]


token = extractToken(document.location.hash)
if token
  document.location.hash = "admin"


waitForReadyToSave = (cb) ->
  return cb() if readyToSave
  setTimeout (-> waitForReadyToSave(cb)), 200


apiCall = (method, url, options, cb) ->
  cb = options unless cb

  xhr = new XMLHttpRequest()

  xhr.onload = -> cb(null, xhr)
  xhr.onerror = -> cb(xhr, null)

  xhr.open(method, "#{resourceHost}/sites/#{document.location.host}#{url}", true)
  xhr.setRequestHeader('Authorization', "Bearer " + token)
  if open.contentType
    xhr.setRequestHeader('Content-Type', )
  if options.body then xhr.send(options.body) else xhr.send()


currentHTMLFile = ->
  path = document.location.pathname
  console.log("Finding currentHTMLFile - files: %o - path: %s", files, path)
  return path if path.match(/\/.html?$/)
  for file in files
    if file.path.match(/\.html?$/)
      filePath = file.path.replace(/\.html?$/, '')
      return file if filePath == path || (path + "index" == filePath || path + "home" == filePath)


saveChanges = (cb) ->
  if document.activeElement == currentElement
    blurHandler()

  patch = []

  return console.log("Saving changes %o", changes) unless token

  for own el of changes
    patch.push
      op: "replace",
      path: el,
      value: changes[el]

  file = currentHTMLFile()

  waitForReadyToSave ->
    apiCall "PATCH", "/files/#{file.path}", {
      body: JSON.stringify(patch)
      contentType: 'application/json-patch+json'
    }, (err, xhr) ->
      console.log("Saved %o", xhr)


position = (element, top, left, width, height) ->
  element.style.top    = "#{top}px"
  element.style.left   = "#{left}px"
  element.style.width  = "#{width}px"
  element.style.height = "#{height}px"


uniqueSelector = (element) ->
  return unless element instanceof Element

  path = []
  while element && element.nodeType == Node.ELEMENT_NODE
    selector = element.nodeName.toLowerCase()
    if element.id
      selector += "#" + element.id
    else
      sibling = element
      nth = 1
      while sibling.nodeType == Node.ELEMENT_NODE && sibling = sibling.previousElementSibling
        nth++
      if nth > 1
        selector += ":nth-child(#{nth})"

    path.unshift(selector)
    if !element.id && (element.parentNode && element.parentNode != document.body)
      element = element.parentNode
    else
      element = null
  path.join(" > ")


highlightElement = (element) ->
  rect = element.getBoundingClientRect()
  top  = window.scrollY + rect.top

  position(highlightElements.top, top, rect.left + 2, rect.width - 4, 0)
  position(highlightElements.rgt, top, rect.left + rect.width + 2, 0, rect.height)
  position(highlightElements.bottom, top + rect.height, rect.left + 2, rect.width - 4, 0)
  position(highlightElements.lft, top, rect.left - 2, 0, rect.height)
  highlightContainer.display = "block"


coverElement = (element, container) ->
  rect = element.getBoundingClientRect()
  container.style.position = "absolute"
  position(container, rect.top + window.scrollY, rect.left + window.scrollX, rect.width, rect.height)


isUIElement = (element) ->
  while element
    return true if element == uiEl || element == highlightContainer
    element = element.parentElement
  false


hoverHandler = (e) ->
  return if isUIElement(e.target)
  highlightElement(e.target)


editHandler = (e) ->
  currentElement.removeAttribute("contentEditable") if currentElement
  currentElement = e.target
  contentBeforeEdit = currentElement.outerHTML
  currentElement.contentEditable = true
  currentElement.focus()
  highlightElement.style.display = "none"


blurHandler = (e) ->
  return unless currentElement
  currentElement.removeAttribute("contentEditable")
  unless contentBeforeEdit == currentElement.outerHTML
    changes[uniqueSelector(e.target)] = currentElement.outerHTML
  contentBeforeEdit = null


imageUploaded = (img, input) ->
  file = input.files[0]
  path = "/uploads/#{file.name}"
  changes[uniqueSelector(img)] = img.outerHTML.replace(/src=((?:"[^"]+")|(?:'[^']+'))/, "src=\"#{path}\"")

  apiCall "PUT", "/files#{path}", {body: file, contentType: "application/octet-stream"}, (err, xhr) ->
    imagesToSave.pop()
    readyToSave = true unless imagesToSave.length


  dataURLReader = new FileReader()

  dataURLReader.onload = (e) ->
    readyToSave = false
    imagesToSave.push(path)

    img.src = dataURLReader.result

  dataURLReader.readAsDataURL(file)

addUIElement = ->
  uiEl = document.createElement("div")
  button = document.createElement("button")
  button.innerHTML = "Save"
  uiEl.appendChild(button)
  uiEl.setAttribute("style", "position: fixed; right: 20px; bottom: 20px;")

  document.body.appendChild(uiEl)
  uiEl.addEventListener "click", (e) ->
    e.preventDefault()
    saveChanges (err) ->
      if err then console.log(err) else console.log("Saved")


addHighlightElements = ->
  highlightContainer = document.createElement("div")
  highlightContainer.display = "none"

  baseStyle = '''
    position: absolute;
    display: block;
    margin: 0;
    padding:0;
    border: 0;
    outline: 2px solid rgba(17,42,244,0.5);
  '''
  for id in ["lft", "rgt", "top", "bottom"]
    el = document.createElement("div")
    el.setAttribute("style", baseStyle)
    highlightContainer.appendChild(el)
    highlightElements[id] = el

  highlightElements["top"].style.outlineColor = "rgba(255,65,100,0.5)"
  highlightElements["rgt"].style.outlineColor = "rgba(0, 145, 247, 0.5)"
  highlightElements["bottom"].style.outlineColor = "rgba(255, 210, 70, 0.5)"
  highlightElements["lft"].style.outlineColor = "rgba(57, 221, 127, 0.5)"

  document.body.appendChild(highlightContainer)


bindImgElements = ->
  imgs = document.querySelectorAll("img")
  for img in imgs
    do (img) ->

      container    = document.createElement("div")
      input        = document.createElement("input")
      input.type   = "file"
      input.accept = "image/*"
      input.style.opacity = "0"
      input.style.display = "block"
      input.style.width   = "100%"
      input.style.height  = "100%"

      container.style.opacity = "0"
      container.style.background = "#eee"
      container.style.zIndex = "999999"
      container.appendChild(input)
      document.body.appendChild(container)
      input.addEventListener "mouseover", (e) ->
        highlightElement(input)
        container.style.opacity = "0.5"
      , false

      input.addEventListener "mouseout", (e) ->
        container.style.opacity = "0"
      , false

      input.addEventListener "change", (e) ->
        imageUploaded(img, input)
      , false

      img.onload = -> coverElement(img, container)
      coverElement(img, container)


bindTextElements = ->
  elements = document.querySelectorAll("h1, h2, h3, h4, h5, h6, div, p, a, span, small, blockquote, label, cite, li")

  for element in elements
    textNodes = (node for node in element.childNodes when node.nodeType == node.TEXT_NODE && node.textContent.replace(/\s/))
    continue unless textNodes.length

    element.addEventListener('mouseover', hoverHandler, false)
    element.addEventListener('click', editHandler, false)
    element.addEventListener('blur', blurHandler, false)


getFileListing = ->
  if token
    apiCall "GET", "/files", (err, xhr) ->
      files = JSON.parse(xhr.responseText)
      readyToSave = true
  else
    readyToSave = true


enterEditingMode = ->
  if !(token || document.location.protocol == "file:")
    authUrl = endUserAuthorizationEndpoint + "?response_type=token&client_id=" + document.location.host + "&redirect_uri=" + window.location
    document.location.href = authUrl
  else
    addUIElement()
    addHighlightElements()
    bindImgElements()
    bindTextElements()
    getFileListing()


checkForEditingMode = () ->
  if document.location.hash == "#admin" || document.location.hash == "#/admin"
    enterEditingMode()
    doOverlay()

doOverlay = ->
  overlayDiv = document.getElementById("forkletOverlay")
  overlayDiv.style.display = 'block'

window.addEventListener "hashchange", ((e) -> checkForEditingMode()), true
checkForEditingMode()
