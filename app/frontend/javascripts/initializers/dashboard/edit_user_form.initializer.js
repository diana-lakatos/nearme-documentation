var form = $('#edit_user');
if (form.length > 0) {
  require.ensure('../../sections/registrations/edit', function(require){
    var EditUserForm = require('../../sections/registrations/edit');
    new EditUserForm(form);
  });
}
