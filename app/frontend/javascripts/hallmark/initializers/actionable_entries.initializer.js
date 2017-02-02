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

  let elsCreatable = document.querySelectorAll('[data-creatable-container]');
  if (elsCreatable.length > 0) {
    require.ensure('../actionable_entries/actionable_entry_create_action',(require) => {
      const ActionableEntryCreateAction = require('../actionable_entries/actionable_entry_create_action');
      Array.prototype.forEach.call(elsCreatable, (entry) => {
        return new ActionableEntryCreateAction(entry);
      });
    });
  }

}

run();

$(document).on('activity-feed-next-page next-page new-comment', run);
