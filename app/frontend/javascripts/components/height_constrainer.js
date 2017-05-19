var HeightConstrainer, asEvented;

asEvented = require('asevented');

/*
 * Class that constrains the height of an element based on the height of another element.
 * Useful for preserving equal height of adjacent fluid elements.
 *
 * Usage:
 *   constrainer = new HeightConstrainer(targetElement, contextElement,
 *     ratio: height/width
 *   )
 *   constrainer.on 'constrained', =>
 *    logic required to run on height changed
 */
HeightConstrainer = function() {
  asEvented.apply(HeightConstrainer.prototype);

  HeightConstrainer.prototype.defaultOptions = {
    /*
     * Only adjust every x milliseconds - for performance reasons, particularly if there are callbacks
     */
    throttle: 25,
    /*
     * (Optional) Ratio for calculating height from width (height = width * ratio), instead of context height
     * eg. If context height is an image, we can't always guarantee it loads. So we provide its known aspect ratio if possible
     */
    ratio: null
  };

  /*
   * targetElement - the element which we're manipulating the height of
   * contextElement - the element which we're basing the height from
   */
  function HeightConstrainer(targetElement, contextElement, options) {
    if (options == null) {
      options = {};
    }
    this.options = $.extend({}, this.defaultOptions, options);
    this.targetElement = $(targetElement);
    this.contextElement = $(contextElement);
    this.bindWindowWatcher();
    this.constrain();
  }

  HeightConstrainer.prototype.bindWindowWatcher = function() {
    return $(window).resize(
      _.throttle(
        function(_this) {
          return function() {
            return _this.constrain();
          };
        }(this),
        this.options.throttle
      )
    );
  };

  HeightConstrainer.prototype.constrain = function() {
    var height;
    if (this.targetElement.is(':visible')) {
      height = this.options.ratio
        ? Math.round(this.contextElement.width() * this.options.ratio)
        : this.contextElement.height();
      this.targetElement.height(height);
      return this.trigger('constrained');
    }
  };

  return HeightConstrainer;
}();

module.exports = HeightConstrainer;
