$(document).on('turbolinks:load', function () {
  $('a.hard_reload').click(function(event) {
    let goTo = $(this).attr('data-target')
    console.log('going to:', goTo)
    location.replace(goTo || '/#')
    location.reload
  })
})