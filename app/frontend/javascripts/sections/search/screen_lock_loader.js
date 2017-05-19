/*
 * Class for displaying ajax loader locking other parts of the screen with transaparent div.
 */
var ScreenLockLoader;

ScreenLockLoader = function() {
  ScreenLockLoader.prototype.lockerClass = 'screen-locker';

  function ScreenLockLoader(containerCallback) {
    this.containerCallback = containerCallback;
    this.showed = false;
  }

  ScreenLockLoader.prototype.show = function() {
    if (this.showed) {
      return;
    }
    this.containerCallback().show();
    $('#content').append(this.locker());
    return this.showed = true;
  };

  ScreenLockLoader.prototype.hide = function() {
    this.containerCallback().hide();
    if (this.lockerElement) {
      this.lockerElement.remove();
    }
    return this.showed = false;
  };

  ScreenLockLoader.prototype.showWithoutLocker = function() {
    return this.containerCallback().show();
  };

  ScreenLockLoader.prototype.locker = function() {
    return this.lockerElement = $('<div>').addClass(this.lockerClass);
  };

  return ScreenLockLoader;
}();

module.exports = ScreenLockLoader;
