ranges = (context = 'body')->

  calculateOutput = ($rangeInput, $outputLeft, $outputRight, max) ->
    per = ((max - $rangeInput.val())*100)/max
    $outputLeft.text(100-per + '%')
    $outputRight.text(per + '%')

  initializeRange = ->
    $rangeInput = $(this).find('input[type=range]')
    $outputLeft = $(this).find('.range-output-left')
    $outputRight = $(this).find('.range-output-right')
    max = $rangeInput.attr('max')

    $rangeInput.on 'change', ->
      calculateOutput($rangeInput, $outputLeft, $outputRight, max)

    calculateOutput($rangeInput, $outputLeft, $outputRight, max)

  $(context).each(initializeRange)

module.exports = ranges
