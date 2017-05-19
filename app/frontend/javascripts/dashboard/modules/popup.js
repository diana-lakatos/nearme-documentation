var Popup,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

Popup = function() {
  function Popup(link) {
    this.openPopup = bind(this.openPopup, this);
    this.link = $(link);
    this.url = this.link.attr('href');
    this.height = this.link.data('popup').height || 440;
    this.width = this.link.data('popup').width || 600;
    this.bindEvents();
  }

  Popup.prototype.bindEvents = function() {
    return this.link.on('click', this.openPopup);
  };

  Popup.prototype.openPopup = function() {
    var newWindow;
    newWindow = window.open(this.url, 'popup', 'height=' + this.height + ',width=' + this.width);
    if (window.focus) {
      newWindow.focus();
    }
    return false;
  };

  return Popup;
}();

module.exports = Popup;
