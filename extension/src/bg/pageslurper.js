(function() {
  var attr, dependencies, element, fetchFile, fetchedFiles, file, files, sourceAttr, _i, _j, _len, _len1;

  fetchFile = function(path, cb) {
    var xhr;
    xhr = new XMLHttpRequest;
    xhr.onload = function() {
      return cb(null, xhr.responseText);
    };
    xhr.onerror = function() {
      console.log("Error fetching file %o", xhr);
      return cb(xhr);
    };
    xhr.open("GET", path, true);
    return xhr.send();
  };

  dependencies = document.querySelectorAll('script[src], link[rel="stylesheet"], img');

  sourceAttr = {
    IMG: "src",
    SCRIPT: "src",
    LINK: "href"
  };

  files = [];

  fetchedFiles = [];

  for (_i = 0, _len = dependencies.length; _i < _len; _i++) {
    element = dependencies[_i];
    attr = sourceAttr[element.nodeName];
    if (!element.getAttribute(attr).match(/^(https?:)?\/\//)) {
      files.push(element.getAttribute(attr));
    }
  }

  console.log("fetching files %o", files);

  for (_j = 0, _len1 = files.length; _j < _len1; _j++) {
    file = files[_j];
    fetchFile(file, function(err, content) {
      fetchedFiles.push(content);
      if (files.length === fetchedFiles.length) {
        return console.log("All files fetced: %o", fetchedFiles);
      }
    });
  }

}).call(this);
