var CompanyForm, DahboardAddressController;

DahboardAddressController = require('./dashboard/address_controller');

CompanyForm = function() {
  function CompanyForm(form) {
    this.form = form;
    this.whiteLabelSettingsEnabler = this.form.find('input[data-white-label-enabler]');
    this.whiteLabelCheckboxes = this.form.find('input[data-white-label-settings]');
    this.whiteLabelSettingsContainer = this.form.find('[data-white-label-settings-container]');
    this.resetLinks = this.form.find('a[data-reset]');
    this.bindEvents();
    this.defSynchronizeCheckboxes();
    this.setDisabled();
    new DahboardAddressController(this.form);
  }

  CompanyForm.prototype.bindEvents = function() {
    this.whiteLabelSettingsEnabler.on(
      'change',
      function(_this) {
        return function() {
          _this.defSynchronizeCheckboxes();
          return _this.setDisabled();
        };
      }(this)
    );
    return this.resetLinks.on(
      'click',
      function(_this) {
        return function(event) {
          var input;
          input = _this.form.find('input[data-color=' + $(event.target).data('reset') + ']');
          if (!input.prop('disabled')) {
            input.val(input.data('default'));
          }
          return false;
        };
      }(this)
    );
  };

  CompanyForm.prototype.setDisabled = function() {
    return this.whiteLabelSettingsContainer
      .find(
        'input[type=text], input[type=tel], input[type=email], input[type=url], input[type=color], input[type=file]'
      )
      .prop('disabled', !this.whiteLabelSettingsEnabler.is(':checked'));
  };

  CompanyForm.prototype.defSynchronizeCheckboxes = function() {
    return this.whiteLabelCheckboxes.prop('checked', this.whiteLabelSettingsEnabler.is(':checked'));
  };

  return CompanyForm;
}();

module.exports = CompanyForm;
