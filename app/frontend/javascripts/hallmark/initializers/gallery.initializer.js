let els = document.querySelectorAll('[data-gallery]');
if (els.length > 0) {
  require.ensure('../gallery/gallery', function(require) {
    var Gallery = require('../gallery/gallery');
    Array.prototype.forEach.call(els, wrapper => {
      return new Gallery(wrapper);
    });
  });
}
