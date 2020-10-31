$(document).on('turbolinks:load', function() {
  M.Modal._count = 0;
  var elems = document.querySelectorAll('.modal');
  var instances = M.Modal.init(elems);
});