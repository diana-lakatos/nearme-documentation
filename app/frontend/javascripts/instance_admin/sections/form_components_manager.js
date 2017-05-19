var InstanceAdminFormComponentsManager;

InstanceAdminFormComponentsManager = function() {
  function InstanceAdminFormComponentsManager() {
    $('select[data-form-component-form-type]').change(function() {
      return location.href = '?form_type=' + $(this).val();
    });
  }

  return InstanceAdminFormComponentsManager;
}();

module.exports = InstanceAdminFormComponentsManager;
