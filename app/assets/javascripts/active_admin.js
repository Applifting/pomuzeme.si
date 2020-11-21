//= require arctic_admin/base
//= require modal
//= require geocomplete
//= require best_in_place
//= require active_admin_datetimepicker
//= require character_counter
//= require remote_tab
//= require requests

$(document).ready(function () {
  $.ajaxSetup({
    headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }
  });

  initialize_remote_tabs()
  init_best_in_place()
});

function init_best_in_place() {
  $('.best_in_place').best_in_place();

  $('.best_in_place').each(function() {
    let callback = $(this).attr('data-callback')

    if(typeof(callback) != "undefined") {
      $(this).bind("ajax:success", function() {
        let callbackFunction = window[callback];

        if(typeof(callbackFunction) === "function") {
          callbackFunction()
        }
      })
    }
  })
}