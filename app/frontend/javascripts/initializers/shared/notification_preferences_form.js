// @flow
let el = document.querySelector('form[data-notification-preferences]');

if (el instanceof HTMLFormElement) {
  require.ensure('../../shared/forms/notification_preferences_form', require => {
    const NotificationPreferencesForm = require('../../shared/forms/notification_preferences_form');
    new NotificationPreferencesForm(el);
  });
}
