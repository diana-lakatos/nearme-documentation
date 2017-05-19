var Dialog,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

Dialog = function() {
  function Dialog() {
    this.setClass = bind(this.setClass, this);
    this.bindEscapeKey = bind(this.bindEscapeKey, this);
    this.hide = bind(this.hide, this);
    this.showContent = bind(this.showContent, this);
    this.showLoading = bind(this.showLoading, this);
    this.show = bind(this.show, this);
    this.load = bind(this.load, this);
    this.build();
    this.bindEvents();
  }

  Dialog.prototype.build = function() {
    this.dialog = $(
      "<div class='dialog' role='dialog' aria-hidden='true' aria-describedby='dialog__title'>\n  <div class='dialog__overlay'>\n  </div>\n  <div class='dialog__container'>\n    <div class='dialog__content'></div>\n      <button type='button' data-modal-close class='dialog__close'>Close</button>\n    </div>\n</div>"
    );
    this.overlay = this.dialog.find('.dialog__overlay');
    this.contentHolder = this.dialog.find('.dialog__content');
    return $('body').append(this.dialog);
  };

  Dialog.prototype.bindEvents = function() {
    this.resetCallbacks();
    this.dialog.on(
      'click',
      '[data-modal-close]',
      function(_this) {
        return function(e) {
          e.preventDefault();
          return _this.hide();
        };
      }(this)
    );

    /*
     * Click on modal button trigger
     */
    $('body').on(
      'click.nearme',
      'a[data-modal]',
      function(_this) {
        return function(e) {
          var ajaxOptions, target;
          e.preventDefault();
          e.stopPropagation();
          target = $(e.currentTarget);
          ajaxOptions = { url: target.attr('href'), data: target.data('ajax-options') };
          return _this.load(ajaxOptions, target.data('modal-class'));
        };
      }(this)
    );

    /*
     * submit form via button
     */
    $('body').on(
      'submit.nearme',
      'form[data-modal]',
      function(_this) {
        return function(e) {
          var ajaxOptions, form;
          e.preventDefault();
          form = $(e.currentTarget);
          ajaxOptions = {
            type: form.attr('method'),
            url: form.attr('action'),
            data: new FormData(e.currentTarget),
            processData: false,
            contentType: false
          };
          return _this.load(ajaxOptions, form.data('modal-class'));
        };
      }(this)
    );
    $(document).on(
      'hide:dialog.nearme',
      function(_this) {
        return function() {
          return _this.hide();
        };
      }(this)
    );
    $(document).on(
      'load:dialog.nearme',
      function(_this) {
        return function(event, ajaxOptions, klass, callbacks) {
          if (ajaxOptions == null) {
            ajaxOptions = {};
          }
          if (klass == null) {
            klass = null;
          }
          if (callbacks == null) {
            callbacks = {};
          }
          return _this.load(ajaxOptions, klass, callbacks);
        };
      }(this)
    );
    return this.overlay.on(
      'click',
      function(_this) {
        return function() {
          return _this.hide();
        };
      }(this)
    );
  };

  Dialog.prototype.resetCallbacks = function() {
    return this.callbacks = { onShow: function() {}, onHide: function() {} };
  };

  Dialog.prototype.load = function(ajaxOptions, klass, callbacks) {
    if (callbacks == null) {
      callbacks = {};
    }
    this.resetCallbacks();
    this.callbacks = $.extend({}, this.callbacks, callbacks);
    this.setClass(klass);
    this.showLoading();
    this.show();
    return $.ajax(ajaxOptions).success(
      function(_this) {
        return function(data) {
          if (data.redirect) {
            return window.location = data.redirect;
          } else if (data.hide) {
            return _this.hide();
          } else {
            return _this.showContent(data);
          }
        };
      }(this)
    );
  };

  Dialog.prototype.show = function() {
    $('body').addClass('dialog--visible');
    this.dialog.attr('aria-hidden', false);
    return this.bindEscapeKey();
  };

  Dialog.prototype.showLoading = function() {
    return this.dialog.removeClass('dialog--loaded');
  };

  Dialog.prototype.showContent = function(content) {
    this.contentHolder.html(content);
    this.dialog.addClass('dialog--loaded');
    $('html').trigger('loaded:dialog.nearme');
    return this.callbacks.onShow();
  };

  Dialog.prototype.hide = function() {
    this.dialog.attr('aria-hidden', true);
    $('body').removeClass('dialog--visible');
    $('body').off('keydown.dialog');
    return this.callbacks.onHide();
  };

  Dialog.prototype.bindEscapeKey = function() {
    return $('body').on(
      'keydown.dialog',
      function(_this) {
        return function(e) {
          if (e.which !== 27) {
            return;
          }
          return _this.hide();
        };
      }(this)
    );
  };

  Dialog.prototype.setClass = function(klass) {
    if (this.customClass) {
      this.dialog.removeClass(this.customClass);
    }
    if (!klass) {
      return;
    }
    this.customClass = klass;
    return this.dialog.addClass(this.customClass);
  };

  return Dialog;
}();

module.exports = Dialog;
