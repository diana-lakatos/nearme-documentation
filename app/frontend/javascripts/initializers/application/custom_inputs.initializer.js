var CustomInputs = require('../../components/custom_inputs');
new CustomInputs();

$(document).on('init:custominputs.nearme', function(){
  return new CustomInputs();
});
