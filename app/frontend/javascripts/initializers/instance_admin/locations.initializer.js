var editLocationForm = $('#edit-location-types-form');
if (editLocationForm.length > 0) {
  require.ensure('../../instance_admin/sections/locations', function(require){
    var InstanceAdminLocationsController = require('../../instance_admin/sections/locations');
    return new InstanceAdminLocationsController(editLocationForm);
  });
}

