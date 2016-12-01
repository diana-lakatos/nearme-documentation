var CustomSelects = require('../../components/custom_selects');
new CustomSelects();

$(document).on('init:customSelects.nearme', function() {
  return new CustomSelects();
});

