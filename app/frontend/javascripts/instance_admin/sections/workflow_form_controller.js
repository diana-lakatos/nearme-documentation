var InstanceAdminWorkflowFormController;

InstanceAdminWorkflowFormController = function() {
  function InstanceAdminWorkflowFormController(form) {
    this.form = form;
    this.alertTypeSelect = this.form.find('select[data-alert-type]');
    this.optionalSettingWrappers = this.form.find('[data-optional-settings]');
    this.bindEvents();
    this.showRecipientSelectOptions(this.alertTypeSelect.val());
  }

  InstanceAdminWorkflowFormController.prototype.bindEvents = function() {
    return this.alertTypeSelect.on(
      'change',
      function(_this) {
        return function(event) {
          return _this.showRecipientSelectOptions($(event.target).val());
        };
      }(this)
    );
  };

  InstanceAdminWorkflowFormController.prototype.showRecipientSelectOptions = function(val) {
    var optionalSettings;
    this.optionalSettingWrappers.find('input, select, textarea').prop('disabled', true);
    this.optionalSettingWrappers.hide();
    optionalSettings = this.form.find('[data-optional-settings-' + val + ']');
    optionalSettings.find('input, select, textarea').prop('disabled', false);
    return optionalSettings.show();
  };

  return InstanceAdminWorkflowFormController;
}();

module.exports = InstanceAdminWorkflowFormController;
