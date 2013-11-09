uiEl = null

removeScriptTagFromDom = ->
  target = document.documentElement
  while target.childNodes.length && target.lastChild.nodeType == 1 # find last HTMLElement child node
    target = target.lastChild;
  # target is now the script element
  target.parentNode.removeChild(target)

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
  document.designMode = false
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
  xhr.send(document.body.parent.outerHTML)

enterEditingMode = ->
  if !(token || document.location.protocol == "file:")
    authUrl = endUserAuthorizationEndpoint + "?response_type=token&client_id=" + document.location.host + "&redirect_uri=" + window.location
    document.location.href = authUrl
  else
    document.designMode = true
    uiEl = document.createElement("div")
    button = document.createElement("button")
    button.innerHTML = "Save"
    uiEl.appendChild(button)
    uiEl.setAttribute("style", "position: fixed; right: 20px; bottom: 20px;")

    document.body.appendChild(uiEl)


if document.location.hash == "#admin"
  enterEditingMode()





