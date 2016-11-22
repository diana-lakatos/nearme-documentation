var form = $('#list-space-flow-form');
if (form.length > 0) {
  require.ensure([
    '../../sections/dashboard/location_controller',
    '../../sections/dashboard/listing_controller',
    '../../sections/space-wizard/space_wizard_list_form',
    '../../sections/categories'
  ], function(require){
    var
      DashboardLocationController = require('../../sections/dashboard/location_controller'),
      DashboardListingController = require('../../sections/dashboard/listing_controller'),
      SpaceWizardSpaceForm = require('../../sections/space-wizard/space_wizard_list_form'),
      CategoriesController = require('../../sections/categories');

    new DashboardLocationController(form);
    new DashboardListingController(form);
    new SpaceWizardSpaceForm(form);
    new CategoriesController(form);
  });
}
