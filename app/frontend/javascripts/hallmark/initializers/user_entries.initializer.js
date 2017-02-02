function run() {
  let els = document.querySelectorAll('[data-user-entry]');

  if (els.length > 0) {
    require.ensure('../user_entries/user_entry', (require) => {
      const UserEntry = require('../user_entries/user_entry');
      Array.prototype.forEach.call(els, (entry) => {
        return new UserEntry(entry);
      });
    });
  }

  let forms = document.querySelectorAll('[data-user-entry-form]');

  if (forms.length > 0) {
    require.ensure('../user_entries/user_entry_form', (require) => {
      const UserEntryForm = require('../user_entries/user_entry_form');
      Array.prototype.forEach.call(forms, (form) => {
        if (form.hasAttribute('data-user-entry-form-initialized')) {
          return;
        }
        let uef = new UserEntryForm();
        uef.setForm(form);
      });
    });
  }
}

run();

$(document).on('activity-feed-next-page next-page new-comment new-user-status', run);
