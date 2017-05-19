var DocumentRequirementsController;

DocumentRequirementsController = function() {
  function DocumentRequirementsController(el) {
    this.container = $(el);
    this.selector = this.container.find('input[type=radio][name*=upload_obligation_attributes]');
    this.documentFields = this.container.find('.document-requirements-fields');
    this.bindEvents();
    this.updateState();
  }

  DocumentRequirementsController.prototype.bindEvents = function() {
    this.selector.on(
      'change',
      function(_this) {
        return function() {
          return _this.updateState();
        };
      }(this)
    );
    return this.documentFields.on('cocoon:before-remove', function(e, fields) {
      var parent;
      parent = $(fields).closest('.nested-container');
      parent.find('input[data-destroy-input]').val('true');
      parent.hide();
      return parent.prependTo(parent.closest('form'));
    });
  };

  DocumentRequirementsController.prototype.updateState = function() {
    if (this.selector.filter(':checked').val() === 'Not Required') {
      return this.hideFields();
    } else {
      return this.showFields();
    }
  };

  DocumentRequirementsController.prototype.showFields = function() {
    this.documentFields.find('input, textarea').prop('disabled', false);
    this.documentFields.find('.disabled').removeClass('disabled');
    return this.documentFields.show();
  };

  DocumentRequirementsController.prototype.hideFields = function() {
    this.documentFields.hide();
    return this.documentFields.find('input, textarea').prop('disabled', true);
  };

  return DocumentRequirementsController;
}();

module.exports = DocumentRequirementsController;
