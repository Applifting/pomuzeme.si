function initialize_remote_tabs() {
  $('.remote-tab-content').each(function() {
    var tabLinkId = $(this).attr('aria-labelledby')
    var contentDivId = $(this).attr('id')
    var url = $(this).attr('data-target')
    var callback = $(this).attr('data-callback')

    $(`#${tabLinkId}`).click(function() {
      getRemoteContent(url, contentDivId, callback)
    })
  })
}

function getRemoteContent(url, elementId, callback) {
  element = $(`#${elementId}`)
  $.ajax({ url: url }).done(function(data) {
    element.empty();
    element.append(data);
    init_best_in_place();

    var callbackFunction = window[callback];
    if(typeof(callbackFunction) === "function") {
      callbackFunction()
    }
  })
}
