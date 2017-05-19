var els = $('.group-form-controller');
if (els.length > 0) {
  require.ensure('../sections/group_form', function(require) {
    var GroupForm = require('../sections/group_form');
    return new GroupForm(els);
  });
}
