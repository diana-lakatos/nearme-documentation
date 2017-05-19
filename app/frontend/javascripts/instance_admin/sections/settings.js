var InstanceAdminSettingsController;

InstanceAdminSettingsController = function() {
  function InstanceAdminSettingsController(container, options) {
    this.container = container;
    this.options = options != null ? options : {};
    this.bindEvents();
  }

  InstanceAdminSettingsController.prototype.bindEvents = function() {
    var settings_container;
    this.container.on('hidden', function() {
      $(this).removeData('modal');
      return $(this).find('.modal-body').html('<p>Loading...</p>');
    });
    $('table.translations input[type=text]').on('change', function() {
      if ($(this).val() === '') {
        return $(this).next().val('true');
      } else {
        return $(this).next().val('false');
      }
    });
    settings_container = $('form.instance_settings');
    return settings_container.find('input#instance_password_protected').on('change', function() {
      if (!$(this).is(':checked')) {
        return settings_container.find('input#instance_marketplace_password').val('');
      }
    });
  };

  return InstanceAdminSettingsController;
}();

module.exports = InstanceAdminSettingsController;
