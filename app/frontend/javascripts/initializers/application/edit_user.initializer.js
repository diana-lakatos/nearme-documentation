var form = $('#edit_user');
if (form.length > 0) {
  require.ensure([ '../../sections/registrations/edit', '../../sections/categories' ], function(
    require
  ) {
    var EditUserForm = require('../../sections/registrations/edit'),
      CategoriesController = require('../../sections/categories');

    new EditUserForm(form);
    new CategoriesController(form);
  });
}
