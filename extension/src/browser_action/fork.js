(function() {
  console.log("Hello, world");

  chrome.tabs.getCurrent(function(tab) {
    console.log("Current tab %o", tab);
    return chrome.pageCapture.saveAsMHTML({
      tabId: tab.id
    }, function(allTheThings) {
      console.log("We have all the things!");
      return console.log(allTheThings);
    });
  });

}).call(this);
