var el = $('form[data-dimensions-template-form]');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/shipping_options/dimensions_templates', function(require){
    var DimensionsTemplates = require('../../instance_admin/sections/shipping_options/dimensions_templates');
    return new DimensionsTemplates(el);
  });
}

