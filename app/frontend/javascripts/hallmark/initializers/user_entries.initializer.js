// @flow
function run() {
  let els = document.querySelectorAll('[data-user-entry]');

  if (els.length > 0) {
    require.ensure('../user_entries/user_entry', require => {
      const UserEntry = require('../user_entries/user_entry');
      Array.prototype.forEach.call(els, (entry: HTMLElement) => {
        new UserEntry(entry);
      });
    });
  }

  let forms = document.querySelectorAll('[data-user-entry-form]');

  if (forms.length > 0) {
    require.ensure('../user_entries/user_entry_form', require => {
      const UserEntryForm = require('../user_entries/user_entry_form');
      Array.prototype.forEach.call(forms, (form: HTMLFormElement) => {
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

jQuery(document).on(
  'activity-feed-next-page next-page new-comment new-user-status',
  run
);
