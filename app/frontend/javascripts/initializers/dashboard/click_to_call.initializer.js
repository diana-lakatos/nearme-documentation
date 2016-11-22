function run(context) {
  var el = context.querySelector('.click-to-call-preferences');
  if (!el) {
    return;
  }

  require.ensure('../../dashboard/modules/click_to_call_preferences', function(require){
    var ClickToCallPreferences = require('../../dashboard/modules/click_to_call_preferences');
    return new ClickToCallPreferences(el);
  });
}

run(document);

$('html').on('loaded:dialog.nearme', function(){
  run(document.querySelector('.dialog'));
});
