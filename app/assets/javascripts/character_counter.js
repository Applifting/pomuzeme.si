function characterCounter (event, limit) {
  let length = event.currentTarget.value.length
  let parent = event.currentTarget.parentNode
  let counter = parent.querySelector('.remainingLength')

  let counter_text = parent.querySelector('#remainingLength')
  counter_text.innerHTML = limit - length

  if (length > limit) {
    counter.style.color = 'red'
  } else {
    counter.style.color = 'inherit'
  }
}

$(document).ready(function () {
  $('.character_counter').each(function() {
    let limit = $(this).attr('data-limit')
    let currentLength = limit - $(this).val().length
    $(this).after(`<p class=\"inline-hints remainingLength\">Zbývá <span id=\"remainingLength\">${currentLength}</span> znaků.</p>`)
    $(this).keyup(function(event) {
      characterCounter(event, limit);
    })
  })
});