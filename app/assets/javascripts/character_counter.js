function characterCounter (event) {
  let length = event.currentTarget.value.length
  $('#remainingLength').text(calcLimit(length))
  if (length > 160) {
    $('p.inline-hints remainingLength').css({ color: 'red' })
  } else {
    $('p.inline-hints remainingLength').css({ color: 'inherit' })
  }
}

function calcLimit(length) {
  return 160 - length;
}

$(document).ready(function () {
  input = $('.character_counter')
  currentLength = calcLimit(input.val().length)
  input.after(`<p class=\"inline-hints remainingLength\">Zbývá <span id=\"remainingLength\">${currentLength}</span> znaků.</p>`)
  input.keyup(function(event) {
    characterCounter(event);
  })
});