function run() {
  let els = document.querySelectorAll('[data-actionable-entry]');

  if (els.length > 0) {
    require.ensure('../actionable_entries/actionable_entry',(require) => {
      const ActionableEntry = require('../actionable_entries/actionable_entry');
      Array.prototype.forEach.call(els, (entry) => {
        return new ActionableEntry(entry);
      });
    });
  }
}

run();

$(document).on('activity-feed-next-page new-comment', run);
