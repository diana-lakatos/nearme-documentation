var ranges;

ranges = function(context) {
  var calculateOutput, initializeRange;
  if (context == null) {
    context = 'body';
  }
  calculateOutput = function($rangeInput, $outputLeft, $outputRight, max) {
    var per;
    per = (max - $rangeInput.val()) * 100 / max;
    $outputLeft.text(100 - per + '%');
    return $outputRight.text(per + '%');
  };
  initializeRange = function() {
    var $outputLeft, $outputRight, $rangeInput, max;
    $rangeInput = $(this).find('input[type=range]');
    $outputLeft = $(this).find('.range-output-left');
    $outputRight = $(this).find('.range-output-right');
    max = $rangeInput.attr('max');
    $rangeInput.on('change', function() {
      return calculateOutput($rangeInput, $outputLeft, $outputRight, max);
    });
    return calculateOutput($rangeInput, $outputLeft, $outputRight, max);
  };
  return $(context).each(initializeRange);
};

module.exports = ranges;
