$(document).on('turbolinks:load', function () {
  $("html, body").animate({
    scrollTop: 0
      }, "slow");
  $('a.hard_reload').click(function(event) {
    let goTo = $(this).attr('data-target')
    location.replace(goTo || '/#')
  })
})

$(document).on('load', function() {
})