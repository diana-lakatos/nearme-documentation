var InstanceAdminPaymentGatewayForm;

InstanceAdminPaymentGatewayForm = function() {
  function InstanceAdminPaymentGatewayForm(form) {
    this.form = form;
    this.bindevents();
  }

  InstanceAdminPaymentGatewayForm.prototype.bindevents = function() {
    this.configSetup();
    return this.form.find('[data-interval]').on(
      'change',
      function(_this) {
        return function() {
          return _this.configSetup();
        };
      }(this)
    );
  };

  InstanceAdminPaymentGatewayForm.prototype.configSetup = function() {
    var form;
    form = this.form;
    return this.form.find('[data-show-if]').each(function() {
      var field, field_data, field_value;
      field_data = '[data-' + $(this).attr('data-show-if').split('-')[0] + ']';
      field_value = $(this).attr('data-show-if').split('-')[1];
      field = form.find(field_data);
      if (field.val() === field_value) {
        $(this).parents('.input-container').show();
        $(this).prop('disabled', false);
      } else {
        $(this).parents('.input-container').hide();
        $(this).prop('disabled', true);
      }
    });
  };

  return InstanceAdminPaymentGatewayForm;
}();

module.exports = InstanceAdminPaymentGatewayForm;
