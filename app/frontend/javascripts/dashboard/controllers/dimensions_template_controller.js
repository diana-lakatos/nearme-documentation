var DimensionsTemplateController;

DimensionsTemplateController = function() {
  function DimensionsTemplateController(container) {
    this.container = $(container);
    this.dimensions_template_fields = $('.dimensions_template');
    this.template = $('[data-dimension-templates]');
    this.shipping_profile = this.container.find('[data-shipping-type]');
    this.toggleFields(this.shipping_profile.filter(':checked'));
    this.bindEvents();
  }

  DimensionsTemplateController.prototype.bindEvents = function() {
    return this.shipping_profile.on(
      'change',
      function(_this) {
        return function(e) {
          return _this.toggleFields($(e.target));
        };
      }(this)
    );
  };

  DimensionsTemplateController.prototype.toggleFields = function(element) {
    var state;
    state = element.data('shipping-type') === 'predefined';
    if (state) {
      this.dimensions_template_fields.hide();
      if (
        this.dimensions_template_fields.find(
          'input#transactable_dimensions_template_attributes__destroy'
        ).length >
          0
      ) {
        this.dimensions_template_fields
          .find('input#transactable_dimensions_template_attributes__destroy')
          .val('1');
      }
    } else {
      this.dimensions_template_fields.removeClass('hidden');
      this.dimensions_template_fields.show();
      if (
        this.dimensions_template_fields.find(
          'input#transactable_dimensions_template_attributes__destroy'
        ).length >
          0
      ) {
        this.dimensions_template_fields
          .find('input#transactable_dimensions_template_attributes__destroy')
          .val('0');
      }
    }
    return this.template.trigger('toggle.dimensiontemplates', [ !state ]);
  };

  return DimensionsTemplateController;
}();

module.exports = DimensionsTemplateController;
