var CustomInputs = require('../../components/custom_inputs');

$(document).on('init:custominputs.nearme', function() {
  return new CustomInputs();
}).trigger('init:custominputs.nearme');
