'use strict';

var HelpBar = function() {
  this.toggler = $('#toggle-help');
  this.helpbar = $('#help-bar');
  this.content = $('.help-bar-content');

  if (this.toggler.length === 0) {
    return;
  }

  this.bindEvents();
  this.initialize();
};

HelpBar.prototype.bindEvents = function() {
  this.toggler.on('click', $.proxy(this.toggle, this));
};

HelpBar.prototype.toggle = function() {
  if (this.helpbar.hasClass('closed')) {
    this.helpbar.animate({ right: 0 }, 400).attr('class', 'open');
    this.content.show();
    this.toggler.attr('class', 'fa fa-long-arrow-right');

    return;
  }

  this.helpbar.animate(
    { right: '-316px' },
    400,
    $.proxy(
      function() {
        this.content.hide();
      },
      this
    )
  );

  this.helpbar.attr('class', 'closed');
  this.toggler.attr('class', 'fa fa-long-arrow-left');
};

HelpBar.prototype.initialize = function() {
  this.content.hide();
};

module.exports = HelpBar;
