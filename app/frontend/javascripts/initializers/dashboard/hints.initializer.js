$('.schedule-exception-rules-container').on('cocoon:after-insert', function(e, insertedElement) {
  require.ensure('../../dashboard/forms/hints', function(require) {
    var hints = require('../../dashboard/forms/hints');
    hints(insertedElement);
  });
});
