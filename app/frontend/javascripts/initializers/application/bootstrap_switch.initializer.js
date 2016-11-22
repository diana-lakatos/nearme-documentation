$(document).on('init:bootstrapswitch.nearme', function(){
  require.ensure('../../components/forms/bootstrap_switch_initializer', function(require){
    var BootstrapSwitchInitializer = require('../../components/forms/bootstrap_switch_initializer');
    return new BootstrapSwitchInitializer('.switch input:visible');
  });
});

var els = $('.switch input:visible');
if (els.length > 0) {
  require.ensure('../../components/forms/bootstrap_switch_initializer', function(require){
    var BootstrapSwitchInitializer = require('../../components/forms/bootstrap_switch_initializer');
    return new BootstrapSwitchInitializer(els);
  });
}
