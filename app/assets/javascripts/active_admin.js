//= require arctic_admin/base
//= require modal
//= require geocomplete
//= require best_in_place
//= require active_admin_datetimepicker
//= require character_counter

$(document).ready(function () {
  $.ajaxSetup({
    headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }
  });

  $('.best_in_place').best_in_place();
});