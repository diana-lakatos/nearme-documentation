var Tutorial, trueResize;

trueResize = require('vendor/trueresize');

Tutorial = function() {
  function Tutorial(el) {
    this.root = $(el);
    this.body = $('body');
    this.slides = this.root.find('.slide');
    this.mask = this.root.find('.mask');
    this.current = this.slides.index(this.slides.filter('.is-active'));
    this.initializeEvents();
    setTimeout(this.init.bind(this), 10);
  }

  Tutorial.prototype.init = function() {
    if (this.root.is('.is-active')) {
      return this.open();
    }
  };

  Tutorial.prototype.show = function(index) {
    var $next, $target, bottom, bounds, doc_height, doc_width, height, left, right, top, width;
    this.slides.removeClass('is-active');
    $next = this.slides.eq(index);
    $target = $($next.data('mask'));
    $next.addClass('is-active');
    bounds = $target.offset();
    width = $target.outerWidth();
    height = $target.outerHeight();
    doc_width = $(document).outerWidth();
    doc_height = $(document).outerHeight();
    top = bounds.top;
    left = bounds.left;
    right = doc_width - bounds.left - width;
    bottom = doc_height - bounds.top - height;
    this.mask.css('border-width', top + 'px ' + right + 'px ' + bottom + 'px ' + left + 'px');
    return this.current = index;
  };

  Tutorial.prototype.open = function() {
    this.root.addClass('is-active');
    this.body.addClass('is-tutorial');
    return this.show(this.current);
  };

  Tutorial.prototype.close = function() {
    this.root.removeClass('is-active');
    return this.body.removeClass('is-tutorial');
  };

  Tutorial.prototype.initializeEvents = function() {
    $(window).on(
      'resize.tutorial',
      $.proxy(
        function() {
          if (!trueResize()) {
            return;
          }
          return this.show(this.current);
        },
        this
      )
    );
    this.root.on(
      'click',
      '[data-next]',
      $.proxy(
        function(event) {
          event.preventDefault();
          return this.show(this.current + 1);
        },
        this
      )
    );
    return this.root.find('[data-close]').on(
      'click',
      $.proxy(
        function(event) {
          event.preventDefault();
          return this.close();
        },
        this
      )
    );
  };

  Tutorial.initialize = function() {
    return $('.tutorial-a').each(function() {
      return new Tutorial(this);
    });
  };

  return Tutorial;
}();

module.exports = Tutorial;
