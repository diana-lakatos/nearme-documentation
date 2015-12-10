(function($) {
  $.fn.slideDownFadeIn = function(speed, slideCallback) {
    var $this = this;

    $this.css({ opacity : 0 });
    $this.slideDown(speed || 'fast', function() {
      $this.css({ opacity : 0 }).animate({opacity : 1}, speed);
      if (slideCallback)
        slideCallback();
    });
  }

  $.fn.fadeOutSlideUp = function(speed, slideCallback) {
    var $this = this;

    $this.animate({opacity: 0}, speed, function() {
      $this.slideUp(speed);
      if (slideCallback)
        slideCallback();
    });
  }
})(jQuery);
