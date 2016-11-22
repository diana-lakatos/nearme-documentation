var els = $('#checkout-form, #list-space-flow-form');
if (els.length > 0) {
  require.ensure('../../sections/draft_validation_controller', function(require){
    var DraftValidationController = require('../../sections/draft_validation_controller');
    els.each(function(){
      return new DraftValidationController(this);
    });
  });
}
