const delegate = require('dom-delegate');

const bodyDelegated = delegate(document.body);

bodyDelegated.on('click', 'a[rel="external"]', (e, target) => {
  e.preventDefault();
  e.stopPropagation();
  window.open(target.href, 'external');
});
