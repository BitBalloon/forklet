uiEl = null

removeScriptTagFromDom = ->
  target = document.documentElement
  while target.childNodes.length && target.lastChild.nodeType == 1 # find last HTMLElement child node
    target = target.lastChild;
  # target is now the script element
  target.parentElement.removeChild(target)

removeScriptTagFromDom()

authHost     = "https://www.bitballoon.com"
resourceHost = "https://www.bitballoon.com/api/v1"
endUserAuthorizationEndpoint = authHost + "/oauth/authorize"

extractToken = (hash) ->
  match = hash.match(/access_token=(\w+)/);
  match && match[1]

token = extractToken(document.location.hash)
if token
  document.location.hash = "admin"

saveChanges = (cb) ->
  console.log("Saving changes")
  document.designMode = "off"
  document.body.removeChild(uiEl)

  xhr = new XMLHttpRequest()
  xhr.onload = ->
    document.designMode = true
    document.body.appendChild(uiEl)
    if xhr.status == 200
      cb(null)
    else
      cb("Error saving to BitBalloon")

  xhr.open("PUT", resourceHost + '/sites/' + document.location.host + '/files/index.html', true)
  xhr.setRequestHeader('Authorization', "Bearer " + token)
  xhr.setRequestHeader('Content-Type', 'application/vnd.bitballoon.v1.raw')
  xhr.send(document.body.parentElement.outerHTML)

coverElement = (element, container) ->
  rect = element.getBoundingClientRect()
  container.style.position = "absolute"
  container.style.top = "#{rect.top + window.scrollY}px"
  container.style.left = "#{rect.left + window.scrollX}px"
  container.style.width = "#{rect.width}px"
  container.style.height = "#{rect.height}px"

enterEditingMode = ->
  if !(token || document.location.protocol == "file:")
    authUrl = endUserAuthorizationEndpoint + "?response_type=token&client_id=" + document.location.host + "&redirect_uri=" + window.location
    document.location.href = authUrl
  else
    console.log "Design mode"
    document.designMode = "on"
    console.log(document.designMode)
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
          container.style.opacity = "0.5"

        input.addEventListener "mouseout", (e) ->
          container.style.opacity = "0"

        input.addEventListener "change", (e) ->
          console.log("files: %o", input.files[0])
          fileReader = new FileReader()

          fileReader.onload = (e) ->
            console.log(e)
            img.src = e.target.result

          fileReader.readAsDataURL(input.files[0])

        img.onload = -> coverElement(img, container)
        coverElement(img, container)


checkForEditingMode = () ->
  if document.location.hash == "#admin" || document.location.hash == "#/admin"
    enterEditingMode()


window.addEventListener "hashchange", ((e) -> checkForEditingMode()), true
checkForEditingMode()
