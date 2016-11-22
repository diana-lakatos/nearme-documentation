var els = $('.group-form-controller');
if (els.length > 0) {
  require.ensure('../../community/sections/group_form', function(require){
    var GroupForm = require('../../community/sections/group_form');
    return new GroupForm(els);
  });
}
