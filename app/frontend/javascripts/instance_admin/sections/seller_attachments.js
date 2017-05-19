var InstanceAdminSellerAttachmentsController;

require('bootstrap-switch/src/coffee/bootstrap-switch');

InstanceAdminSellerAttachmentsController = function() {
  function InstanceAdminSellerAttachmentsController(container) {
    this.container = container;
    this.initializeBootstrapSwitch();
  }

  InstanceAdminSellerAttachmentsController.prototype.initializeBootstrapSwitch = function() {
    this.container
      .find('[data-activate-seller-attachments]')
      .bootstrapSwitch({ inverse: true, size: 'mini' });
    return this.container.find('[data-activate-seller-attachments]').on(
      'switchChange.bootstrapSwitch',
      function(_this) {
        return function(event) {
          var descriptionForEnabled, optionsWrapper;
          optionsWrapper = _this.container.find('[data-options-wrapper]');
          descriptionForEnabled = _this.container.find('[data-description-for-enabled]');
          if (event.type === 'switchChange') {
            if (_this.container.find('[data-activate-seller-attachments]').is(':checked')) {
              optionsWrapper.removeClass('hide');
              return descriptionForEnabled.removeClass('hide');
            } else {
              optionsWrapper.addClass('hide');
              return descriptionForEnabled.addClass('hide');
            }
          }
        };
      }(this)
    );
  };

  return InstanceAdminSellerAttachmentsController;
}();

module.exports = InstanceAdminSellerAttachmentsController;
