var InstanceWizardForm;

InstanceWizardForm = function() {
  function InstanceWizardForm(el) {
    this.form = $(el);
    this.domainInput = this.form.find('input[data-domain-name]');
    this.bindEvents();
  }

  InstanceWizardForm.prototype.bindEvents = function() {
    return this.domainInput.on('input', function() {
      var value;
      value = $(this).val().replace(/[^\w\.\-]/gi, '');
      return $(this).val(value.toLowerCase());
    });
  };

  return InstanceWizardForm;
}();

module.exports = InstanceWizardForm;
