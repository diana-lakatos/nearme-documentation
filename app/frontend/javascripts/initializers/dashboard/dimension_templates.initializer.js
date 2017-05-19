var els = $('[data-shipping-methods-list]');
if (els.length > 0) {
  require.ensure('../../dashboard/controllers/dimensions_template_controller', function(require) {
    var DimensionsTemplateController = require(
      '../../dashboard/controllers/dimensions_template_controller'
    );
    els.each(function() {
      return new DimensionsTemplateController(this);
    });
  });
}

$(document).on('init:dimensiontemplates.nearme', function(event, el, units) {
  require.ensure('../../dashboard/modules/dimension_templates', function(require) {
    var DimensionTemplates = require('../../dashboard/modules/dimension_templates');
    new DimensionTemplates(el, units);
  });
});
