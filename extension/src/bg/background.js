(function() {
  chrome.browserAction.onClicked.addListener(function(tab) {
    alert("test");
    console.log("Click on %o", tab);
    return chrome.pageCapture.saveAsMHTML({
      tabId: tab.id
    }, function(allTheThings) {
      var reader;
      console.log("We have all the things!");
      console.log(allTheThings);
      reader = new FileReader;
      reader.onload = function(e) {
        console.log("Die console, die:");
        return console.log(e.target.result);
      };
      return reader.readAsBinaryString(allTheThings);
    });
  });

  chrome.extension.onMessage.addListener(function(request, sender, sendResponse) {
    chrome.pageAction.show(sender.tab.id);
    return sendResponse();
  });

}).call(this);
