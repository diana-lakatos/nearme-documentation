var SocialButtons = function(element, plugin) {
  this.wrapper = element;
  this.buttons = element.querySelectorAll('.socialite');
  this.plugin = plugin;

  this.setup();
  this.bindEvents();
};

SocialButtons.prototype.setup = function() {
  var that = this;

  this.plugin.setup({
    facebook: { appId: getOption('.facebook-like', 'data-app-id') },
    twitter: {},
    googleplus: {}
  });

  function getOption(selector, attr) {
    var btn = that.wrapper.querySelector(selector);

    if (btn && btn.getAttribute(attr)) {
      return btn.getAttribute(attr);
    }
  }
};

SocialButtons.prototype.bindEvents = function() {
  var that = this;

  $(window).load(function() {
    that.init();
  });
};

SocialButtons.prototype.init = function() {
  var that = this, counter = 0;

  that.plugin.load(that.wrapper, null, null, function() {
    counter += 1;

    if (counter === that.buttons.length) {
      that.wrapper.classList.add('active');
    }
  });
};

module.exports = SocialButtons;
