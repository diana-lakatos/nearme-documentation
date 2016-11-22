var els = $('#white-label-form');
if (els.length > 0) {
  require.ensure('../../dashboard/controllers/white_label_controller', function(require){
    var WhiteLabelController = require('../../dashboard/controllers/white_label_controller');
    els.each(function(){
      return new WhiteLabelController(this);
    });
  });
}

/* This is to fix the wrong state of white-label-fields (shown or not shown) due to white_label_enabled checkbox keeping the same state on page refresh even though it's not persisted in the DB */
var
  el = $('#company_white_label_enabled'),
  fields = $('#white-label-fields');

if(el.is(':checked')) {
  fields.attr('class', 'collapse in');
}
else {
  fields.attr('class', 'collapse');
}
