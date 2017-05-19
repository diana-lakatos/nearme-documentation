var FlashMessage;

FlashMessage = function() {
  function FlashMessage(el) {
    this.message = $(el);
    this.initStructure();
    this.addEventListeners();
  }

  FlashMessage.prototype.initStructure = function() {
    var btn, closeLabel;
    closeLabel = this.message.data('close-label');
    btn = $(
      "<button type='button' class='close'><span class='intelicon-close-solid'></span> " +
        closeLabel +
        '</button>'
    );
    return this.message.find('.contain').append(btn);
  };

  FlashMessage.prototype.addEventListeners = function() {
    return this.message.on(
      'click',
      '.close',
      function(_this) {
        return function() {
          return _this.message.slideUp();
        };
      }(this)
    );
  };

  return FlashMessage;
}();

module.exports = FlashMessage;
