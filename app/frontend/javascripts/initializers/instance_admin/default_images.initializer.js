if (document.querySelector('[data-default-images]')) {
  require.ensure('../../instance_admin/forms/default_images', function(require) {
    var DefaultImages = require('../../instance_admin/forms/default_images');
    return new DefaultImages();
  });
}
