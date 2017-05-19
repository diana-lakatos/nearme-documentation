import NM from 'nm';
let Notification = require('notification');

class NotificationsController {
  constructor() {
    NM.on('create:notification', (options = {}) => {
      return new Notification(options);
    });

    this.createNotificationsFromDOM();
  }

  createNotificationsFromDOM() {
    let notifications = document.querySelectorAll('#notification-area .notification');

    Array.prototype.forEach.call(notifications, el => {
      if (el.getAttribute('data-initialised')) {
        return;
      }

      let options = { element: el };
      let autoclose = el.getAttribute('data-notification-autoclose');
      if (autoclose) {
        options.autoclose = parseInt(autoclose, 10);
      }
      new Notification(options);
    });
  }
}

module.exports = new NotificationsController();
