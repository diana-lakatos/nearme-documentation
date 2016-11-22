var els = $('[data-instance-wizard-form]');
if (els.length > 0) {
  require.ensure('../../instance_wizard/instance_wizard_form', function(require){
    var InstanceWizardForm = require('../../instance_wizard/instance_wizard_form');
    els.each(function(){
      return new InstanceWizardForm(this);
    });
  });
}
