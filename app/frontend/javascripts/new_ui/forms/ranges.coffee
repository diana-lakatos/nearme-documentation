ranges = (context = 'body')->
  $rangeInput = $(context).find('input[type=range]')
  $outputLeft = $(context).find('.range-output-left')
  $outputRight = $(context).find('.range-output-right')
  max = $rangeInput.attr('max')

  calculateOutput = ->
    per = ((max - $rangeInput.val())*100)/max
    $outputLeft.text(100-per + '%')
    $outputRight.text(per + '%')

  $rangeInput.on 'change', ->
    calculateOutput()

  calculateOutput()

module.exports = ranges
