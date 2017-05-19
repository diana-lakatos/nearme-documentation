var CustomInputs, Modal;

require('../../vendor/bootstrap-modal-fullscreen');

CustomInputs = require('../components/custom_inputs');

/*
 * A simple modal implementation
 *
 * FIXME: Requires pre-existing HTML markup
 * TODO: This is just a first-cut. We can tidy this up and allow further customisation etc.
 *
 * Usage:
 *   # Load a URL and have Modal handle all the loading view and content showing, etc:
 *   Modal.load("/my/url")
 *
 *   Manually trigger the loading view of a visible modal:
 *   Modal.showLoading()
 *
 *   Manually update the content of a visible modal:
 *   Modal.showContent("my new content")
 */
Modal = function() {
  Modal.reloadOnClose = function(url) {
    return this._reloadOnClose = url;
  };

  /*
   * Listen for click events on modalized links
   * Modalized links are anchor elements with rel="modal"
   * A custom class can be specified on the modal:
   *   <a href="modalurl" rel="modal.my-class">link</a>
   */
  Modal.listen = function() {
    $('body').delegate(
      'a[data-modal]',
      'click',
      function(_this) {
        return function(e) {
          _this.modalClicked(e);
          return false;
        };
      }(this)
    );
    $('body').delegate(
      'a[rel*="modal"]',
      'click',
      function(_this) {
        return function(e) {
          _this.modalClickedLegacy(e);
          return false;
        };
      }(this)
    );
    $('body').delegate('form[data-modal]', 'submit', function(e) {
      var form, modalClass, overlayCloseDisabled;
      e.preventDefault();
      form = $(e.currentTarget);
      modalClass = null;
      overlayCloseDisabled = form.data('modal-overlay-close') === 'disabled';
      if (form.is('form[data-modal-class]')) {
        modalClass = form.attr('data-modal-class');
      }
      Modal.load(
        {
          type: 'POST',
          url: form.attr('action'),
          data: new FormData(form.get(0)),
          processData: false,
          contentType: false
        },
        modalClass,
        overlayCloseDisabled
      );
      return false;
    });
    $(document).on(
      'ajaxSend',
      '.modal-content form',
      function(_this) {
        return function() {
          return _this.showLoading();
        };
      }(this)
    );
    return $(document).on('ajaxSuccess', '.modal-content form', function(event, data) {
      return Modal.showContent(data);
    });
  };

  Modal.modalClickedLegacy = function(e) {
    var ajaxOptions, matches, modalClass, target;
    e.preventDefault();
    target = $(e.currentTarget);
    matches = target.attr('rel').match(/modal\.([^\s]+)/);
    if (matches) {
      modalClass = matches[1];
    }
    ajaxOptions = { url: target.attr('href'), data: target.data() };
    this.load(ajaxOptions, modalClass);
    return false;
  };

  Modal.modalClicked = function(e) {
    var ajaxOptions, modalClass, overlayCloseDisabled, target;
    e.preventDefault();
    target = $(e.currentTarget);
    modalClass = null;
    overlayCloseDisabled = target.data('modal-overlay-close') === 'disabled';
    if (target.is('a[data-modal-class]')) {
      modalClass = target.attr('data-modal-class');
    }
    ajaxOptions = { url: target.attr('data-href'), data: target.attr('data-ajax-options') };
    return this.load(ajaxOptions, modalClass, overlayCloseDisabled);
  };

  /*
   * Show the loading status on the modal
   */
  Modal.showLoading = function() {
    return this.instance().showLoading();
  };

  /*
   * Show the content on the modal
   */
  Modal.showContent = function(content) {
    return this.instance().showContent(content);
  };

  /*
   * Trigger laoding of the URL within the modal via AJAX
   */
  Modal.load = function(ajaxOptions, modalClass, overlayCloseDisabled, callback) {
    if (modalClass == null) {
      modalClass = null;
    }
    if (overlayCloseDisabled == null) {
      overlayCloseDisabled = false;
    }
    if (callback == null) {
      callback = null;
    }
    this.instance().setClass(modalClass);
    this.instance().setOverlayCloseDisabled(overlayCloseDisabled);
    this.instance().load(ajaxOptions);
    return this.instance().setCallback(callback);
  };

  Modal.setClass = function(klass) {
    return this.instance().setClass(klass);
  };

  Modal.close = function() {
    return this.instance().hide();
  };

  /*
   * ===
   */
  function Modal(options) {
    this.options = options;
    console.log('Modal :: Initializing');
    this.container = $('.modal-container');
    this.content = this.container.find('.modal-content');
    this.loading = this.container.find('.modal-loading');
    this.bodyContainer = $('.dnm-page-body');
    this.overlay = $('.modal-overlay');
    this.overlayCloseDisabled = false;

    /*
     * Bind to any element with "close" class to trigger close on the modal
     */
    this.container.delegate(
      '.close-modal, .modal-close, .modal-close-manually',
      'click',
      function(_this) {
        return function(e) {
          e.preventDefault();
          return _this.hide();
        };
      }(this)
    );

    /*
     * Bind to the overlay to close the modal
     */
    this.overlay.bind(
      'click',
      function(_this) {
        return function() {
          if (!_this.overlayCloseDisabled) {
            return _this.hide();
          }
        };
      }(this)
    );
  }

  Modal.prototype.setCallback = function(callback) {
    return this.callback = callback;
  };

  Modal.prototype.setOverlayCloseDisabled = function(overlayCloseDisabled) {
    return this.overlayCloseDisabled = overlayCloseDisabled;
  };

  Modal.prototype.setClass = function(klass) {
    if (this.customClass) {
      this.container.removeClass(this.customClass);
    }
    this.customClass = klass;
    if (klass) {
      return this.container.addClass(klass);
    }
  };

  Modal.prototype.showContent = function(content) {
    var error;
    this._show();
    this.container.removeClass('loading');
    this.loading.hide();
    if (content) {
      this.content.html('');
    }
    this.content.show();
    if (content) {
      if (window.Raygun) {
        try {
          this.content.html(content);
        } catch (error1) {
          error = error1;
          window.Raygun.send(error, content);
          throw error;
        }
      } else {
        this.content.html(content);
      }
    }
    new CustomInputs(this.container);

    /*
     * We need to ensure there has been a reflow displaying the target element
     * before applying the class with the animation transitions
     */
    return setTimeout(
      function(_this) {
        return function() {
          return _this.content.addClass('visible');
        };
      }(this),
      20
    );
  };

  Modal.prototype.showLoading = function() {
    this.container.addClass('loading');
    this.content.hide();
    return this.loading.show();
  };

  Modal.prototype.hide = function() {
    this.content.removeClass('visible');
    this.overlay.removeClass('visible');
    this.container.removeClass('visible');

    /*
     * We need to ensure our transitions have had enough time to execute
     * prior to hiding the element.
     */
    setTimeout(
      function(_this) {
        return function() {
          _this.overlay.hide();
          _this.container.hide();

          /*
         * Clear any assigned modal class
         */
          _this.setClass(null);
          _this.setOverlayCloseDisabled(false);
          _this._unfixBody();
          if (_this.callback) {
            return _this.callback();
          }
        };
      }(this),
      200
    );
    $('body').off('keydown.modalclose');

    /*
     * Redirect if bound
     */
    if (Modal._reloadOnClose) {
      return window.location = Modal._reloadOnClose;
    }
  };

  /*
   * Trigger visibility of the modal
   */
  Modal.prototype._show = function() {
    this._fixBody();
    this.overlay.show();
    this.container.show();
    this.positionModal();

    /*
     * We need to ensure there has been a reflow displaying the target element
     * before applying the class with the animation transitions
     */
    setTimeout(
      function(_this) {
        return function() {
          _this.overlay.addClass('visible');
          return _this.container.addClass('visible');
        };
      }(this),
      20
    );

    /*
     * start listening to ESC keypress
     */
    return $('body').on(
      'keydown.modalclose',
      function(_this) {
        return function(e) {
          if (e.which === 27) {
            return _this.hide();
          }
        };
      }(this)
    );
  };

  /*
   * Load the given URL in the modal
   * Displays the modal, shows the loading status, fires an AJAX request and
   * displays the content
   */
  Modal.prototype.load = function(ajaxOptions) {
    var request;
    this._show();
    this.showLoading();
    request = $.ajax(ajaxOptions);
    return request.success(
      function(_this) {
        return function(data) {
          if (data.redirect) {
            return document.location = data.redirect;
          } else if (data.hide) {
            _this.content.html('');
            return _this.hide();
          } else {
            _this.showContent(data);
            if (_this.callback) {
              return _this.callback();
            }
          }
        };
      }(this)
    );
  };

  /*
   * Position the modal on the page.
   */
  Modal.prototype.positionModal = function() {
    var width;
    width = this.container.outerWidth();

    /*
     * FIXME: Pass these in as configuration options to the modal
     */
    return this.container.css({
      position: 'absolute',
      top: '50px',
      left: '50%',
      'margin-left': '-' + parseInt(width / 2) + 'px'
    });
  };

  Modal.prototype._bodyIsFixed = function() {
    return this.bodyContainer.is('.modal-body-wrapper');
  };

  /*
   * Fix the position of the main page content, preventing scrolling and allowing the window scrollbar to scroll the modal's content instead.
   */
  Modal.prototype._fixBody = function() {
    if (this._bodyIsFixed()) {
      return;
    }
    this._scrollTopWas = $(window).scrollTop();
    this.bodyContainer
      .addClass('modal-body-wrapper')
      .css({ 'margin-top': '-' + this._scrollTopWas + 'px' });
    return $(window).scrollTop(0);
  };

  /*
   * Reverse the 'fixing' of the primary page content
   */
  Modal.prototype._unfixBody = function() {
    if (!this._bodyIsFixed()) {
      return;
    }
    this.bodyContainer.removeClass('modal-body-wrapper').css({ 'margin-top': 'auto' });
    return $(window).scrollTop(this._scrollTopWas);
  };

  /*
   * Get the instance of the Modal object
   */
  Modal.instance = function() {
    return window.modal || (window.modal = new Modal());
  };

  return Modal;
}();

module.exports = Modal;
