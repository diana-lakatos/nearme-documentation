var InstanceAdminDocumentsUploadController;

require('bootstrap-switch/dist/js/bootstrap-switch');

InstanceAdminDocumentsUploadController = function() {
  function InstanceAdminDocumentsUploadController(container) {
    this.container = container;
    this.initializeBootstrapSwitch();
  }

  InstanceAdminDocumentsUploadController.prototype.initializeBootstrapSwitch = function() {
    this.container
      .find('[data-activate-upload-files]')
      .bootstrapSwitch({ inverse: true, size: 'mini' });
    return this.container.find('[data-activate-upload-files]').on(
      'switchChange.bootstrapSwitch',
      function(_this) {
        return function(event) {
          var descriptionForDisabled, descriptionForEnabled, optionsWrapper;
          optionsWrapper = _this.container.find('[data-options-wrapper]');
          descriptionForEnabled = _this.container.find('[data-description-for-enabled]');
          descriptionForDisabled = _this.container.find('[data-description-for-disabled]');
          if (event.type === 'switchChange') {
            if (_this.container.find('[data-activate-upload-files]').is(':checked')) {
              optionsWrapper.removeClass('hide');
              descriptionForDisabled.addClass('hide');
              return descriptionForEnabled.removeClass('hide');
            } else {
              optionsWrapper.addClass('hide');
              descriptionForDisabled.removeClass('hide');
              return descriptionForEnabled.addClass('hide');
            }
          }
        };
      }(this)
    );
  };

  return InstanceAdminDocumentsUploadController;
}();

module.exports = InstanceAdminDocumentsUploadController;
