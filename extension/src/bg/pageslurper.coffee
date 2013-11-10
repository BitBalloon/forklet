#
# Copyright (c) 2012 T. Michael Keesey
# LICENSE: http://opensource.org/licenses/MIT
#
`var sha1;(function(h){var f=Math.pow(2,24);var c=Math.pow(2,32);function d(m){var l="",j;for(var k=7;k>=0;--k){j=(m>>>(k<<2))&15;l+=j.toString(16)}return l}function e(j,i){return((j<<i)|(j>>>(32-i)))}var b=(function(){function i(j){this.bytes=new Uint8Array(j<<2)}i.prototype.get=function(j){j<<=2;return(this.bytes[j]*f)+((this.bytes[j+1]<<16)|(this.bytes[j+2]<<8)|this.bytes[j+3])};i.prototype.set=function(j,m){var l=Math.floor(m/f),k=m-(l*f);j<<=2;this.bytes[j]=l;this.bytes[j+1]=k>>16;this.bytes[j+2]=(k>>8)&255;this.bytes[j+3]=k&255};return i})();function a(k){k=k.replace(/[\u0080-\u07ff]/g,function(n){var i=n.charCodeAt(0);return String.fromCharCode(192|i>>6,128|i&63)});k=k.replace(/[\u0080-\uffff]/g,function(n){var i=n.charCodeAt(0);return String.fromCharCode(224|i>>12,128|i>>6&63,128|i&63)});var m=k.length,l=new Uint8Array(m);for(var j=0;j<m;++j){l[j]=k.charCodeAt(j)}return l.buffer}function g(F){var v;if(F instanceof ArrayBuffer){v=F}else{v=a(String(F))}var q=1732584193,p=4023233417,o=2562383102,n=271733878,m=3285377520,C,A=v.byteLength,x=A<<3,K=x+65,z=Math.ceil(K/512)<<9,u=z>>>3,L=u>>>2,t=new b(L),N=t.bytes,B,r=new Uint32Array(80),l=new Uint8Array(v);for(C=0;C<A;++C){N[C]=l[C]}N[A]=128;t.set(L-2,Math.floor(x/c));t.set(L-1,x&4294967295);for(C=0;C<L;C+=16){for(B=0;B<16;++B){r[B]=t.get(C+B)}for(;B<80;++B){r[B]=e(r[B-3]^r[B-8]^r[B-14]^r[B-16],1)}var M=q,J=p,I=o,H=n,E=m,D,y,G;for(B=0;B<80;++B){if(B<20){D=(J&I)|((~J)&H);y=1518500249}else{if(B<40){D=J^I^H;y=1859775393}else{if(B<60){D=(J&I)^(J&H)^(I&H);y=2400959708}else{D=J^I^H;y=3395469782}}}G=(e(M,5)+D+E+y+r[B])&4294967295;E=H;H=I;I=e(J,30);J=M;M=G}q=(q+M)&4294967295;p=(p+J)&4294967295;o=(o+I)&4294967295;n=(n+H)&4294967295;m=(m+E)&4294967295}return d(q)+d(p)+d(o)+d(n)+d(m)}h.hash=g})(sha1||(sha1={}));`

window.forkletActive = true

authHost     = "https://www.bitballoon.com"
resourceHost = "https://www.bitballoon.com/api/v1"
scriptEndpoint = "<script src='http://on-site-snippet.bitballoon.com/js/on-site.js'></script>"
apiToken = "9dda61b2f010b674a787cb102f119423c817b609930596f66835a91b200cf9cd"

# authHost     = "http://www.bitballoon.lo:9393"
# resourceHost = "http://www.bitballoon.lo:9393/api/v1"
# scriptEndpoint = "<script src='http://on-site-scripts.bitballoon.lo:9393/js/on-site.js'></script>"
# apiToken = "009084e8f8ddf052592b0d112b4384e5a3e80106172d9a3a1fee0439299c09ae"
endUserAuthorizationEndpoint = authHost + "/oauth/authorize"

absolutePath = /^((?:[\w_-]+:)?\/\/|data:)/

for el in document.querySelectorAll("script[src^='chrome-extension://'], link[href^='chrome-extension://']")
  el.parentNode.removeChild(el)

for a in document.querySelectorAll("a[href]")
  a.setAttribute("href", a.href) unless a.getAttribute("href").match(absolutePath)

str2ab = (str) ->
  buf = new ArrayBuffer(str.length*2) # 2 bytes for each char
  bufView = new Uint16Array(buf)
  for char, i in str
    bufView[i] = str.charCodeAt(i)
  buf


doctype = ->
  node = document.doctype;
  html = "<!DOCTYPE #{node.name}" +
         (node.publicId ? ' PUBLIC "' + node.publicId + '"' : '') +
         (!node.publicId && node.systemId ? ' SYSTEM' : '') +
         (node.systemId ? ' "' + node.systemId + '"' : '') +
         '>';

ajax = (method, path, options, cb) ->
  unless cb
    cb = options
    options = {}

  options.retries = 3

  xhr = new XMLHttpRequest

  xhr.onload = ->
    console.log("Request done %o", xhr)
    cb(null, xhr)
  xhr.onerror = ->
    if options.retries > 0 && (method == "PUT" || method == "GET") && xhr.status != 422
      options.retries -= 1
      ajax(method, path, options, cb)
    else
      console.log("Error fetching file %o", xhr)
      cb(xhr)

  xhr.open method, path, true

  xhr.responseType = "blob" if options.blob

  for own header, value of options.headers || {}
    xhr.setRequestHeader(header, value)

  if options.body then xhr.send(options.body) else xhr.send()


waitForReady = (site, cb) ->
  ajax "GET", "#{resourceHost}/sites/#{site.id}", {headers: {"Authorization": "Bearer " + apiToken}}, (err, xhr) ->
    return cb(err) if err

    site = JSON.parse(xhr.responseText)
    if site.state == "current"
      cb(null, site)
    else
      setTimeout((-> waitForReady(site, cb)), 1000)


pageContent = document.documentElement.outerHTML
pageContent += scriptEndpoint

overlay = document.createElement("div")
overlay.style.position   = "fixed"
overlay.style.top        = "0px"
overlay.style.width      = "100%"
overlay.style.height     = "100%"
overlay.style.background = "linear-gradient(rgba(15, 15, 15, 0.91), rgba(17, 16, 16, 0.78))"
overlay.style.zIndex     = "99999"

spinner = document.createElement("iframe")
spinner.style.position = "absolute"
spinner.style.top = "0px"
spinner.style.left = "0px"
spinner.style.width = "100%"
spinner.style.height = "100%"
spinner.style.overflow = "hidden"
spinner.frameBorder = "0"
spinner.src = chrome.extension.getURL("src/spinner.html")

overlay.appendChild(spinner)

document.body.appendChild(overlay)

dependencies = document.querySelectorAll('script[src], link[rel="stylesheet"], img')

sourceAttr =
  IMG: "src"
  SCRIPT: "src"
  LINK: "href"

files = []
fetchedFiles = []

createSite = ->
  fetchedFiles.push({path: "/index.html", content: "#{doctype()}\n#{pageContent}"})

  manifest = {}
  for file in fetchedFiles
    manifest[file.path] = sha1.hash(file.content).toString()

  console.log("All files fetced: %o", manifest)
  console.log(fetchedFiles)

  ajax "POST", "#{resourceHost}/sites", {
    headers: {"Content-Type": "application/json", "Authorization": "Bearer " + apiToken}
    body: JSON.stringify({
      files: manifest
      # snippets: [{
      #   title: "On site editing"
      #   general: "<script src='http://on-site-snippet.bitballoon.com/js/on-site.js'></script>"
      # }]
      processors: ["forms"]
    })
  }, (err, xhr) ->
    return alert("Failed to created site") if err

    site = JSON.parse(xhr.responseText)

    uploaded = []
    toUpload = []

    for sha in site.required
      for file in fetchedFiles
        console.log("Checking %o - %o - %o", sha, file.path, manifest[file.path])
        toUpload.push(file) if manifest[file.path] == sha

    console.log("Required %o", site.required)
    console.log("Uploading %o", toUpload)

    for file in toUpload
      do (file) ->
        ajax "PUT", "#{resourceHost}/sites/#{site.id}/files#{file.path}", {
          headers: {"Content-Type": "application/octet-stream", "Authorization": "Bearer " + apiToken}
          body: file.content
        }, (err, xhr) ->
          return console.log("Error uploading file") if err

          uploaded.push(file)
          if uploaded.length == toUpload.length
            waitForReady site, (err, site) ->
              document.location.href = site.url + "#access_token=#{apiToken}"

host = "#{document.location.protocol}//#{document.location.hostname}#{if document.location.port then ":#{document.location.port}" else ""}"

for element in dependencies
  attr = sourceAttr[element.nodeName]
  unless element.getAttribute(attr).match(absolutePath)
    files.push(element.getAttribute(attr))

for sheet in document.styleSheets
  continue unless sheet.href && sheet.href.indexOf(host) == 0
  for rule in (sheet.rules || [])
    rule.cssText.replace /(url\(\s*((?:"[^\"]+")|(?:'[^\']+')|(?:[^\)]+))\s*\))/mg, (s, _, url) ->
      url = url.replace(/(^["']|["']$)/).replace(new RegExp("^" + host), '')
      files.push(url) unless url.match(absolutePath)
      s

if files.length
  for path in files
    do (path) ->
      ajax "GET", path, {blob: true}, (err, xhr) ->
        reader = new FileReader
        reader.onload = ->
          console.log("Got arrayBuffer for %s", path)
          fetchedFiles.push({path: path.replace(/^([^\/])/, "/$1"), content: reader.result})

          if files.length == fetchedFiles.length
            createSite()
        reader.readAsArrayBuffer(xhr.response)
else
  createSite()