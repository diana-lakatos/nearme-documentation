let els = document.querySelectorAll('[data-paginable-container]');

if (els.length > 0) {
  require.ensure('../paginable_container', require => {
    let PaginableContainer = require('../paginable_container');

    Array.prototype.forEach.call(els, el => {
      new PaginableContainer(el);
    });
  });
}
