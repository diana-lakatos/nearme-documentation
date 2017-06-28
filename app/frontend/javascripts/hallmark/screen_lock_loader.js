/*
 * Class for displaying ajax loader locking other parts of the screen with transaparent div.
 */

const LOCKER_CLASS = 'screen-locker';

class ScreenLockLoader {
  constructor(containerCallback) {
    this.containerCallback = containerCallback;
    this.showed = false;
  }

  show() {
    if (this.showed) {
      return;
    }
    this.containerCallback().show();
    $('#content').append(this.locker());
    this.showed = true;
  }

  hide() {
    this.containerCallback().hide();
    if (this.lockerElement) {
      this.lockerElement.remove();
    }
    this.showed = false;
  }

  showWithoutLocker() {
    this.containerCallback().show();
  }

  locker() {
    this.lockerElement = $('<div>').addClass(LOCKER_CLASS);
  }
}

module.exports = ScreenLockLoader;
