let run = function(elements) {
  if (elements.length === 0) {
    return;
  }

  console.log(elements);

  require.ensure('../../components/limited_input', function(require) {
    var LimitedInput = require('../../components/limited_input');
    Array.prototype.forEach.call(elements, el => {
      new LimitedInput(el);
    });
  });
};

$(document).on('init:limiter.nearme', function(event, elements) {
  if (typeof elements === 'string') {
    elements = document.querySelectorAll(elements);
  }
  run(elements);
});

run(document.querySelectorAll('[data-counter-limit]'));
