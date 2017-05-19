/*
 * Base class for positioned view modal containers generated client-side
 *
 * Used for the Datepicker and TimePicker modals.
 */
var PositionedView;

PositionedView = function() {
  PositionedView.prototype.containerTemplate = '<div></div>';

  PositionedView.prototype.defaultOptions__PositionedView = {
    positionTarget: null,
    containerClass: null,
    windowRightPadding: 20,
    positionPadding: 5
  };

  function PositionedView(options) {
    this.options = options;
    this.options = $.extend({}, this.defaultOptions__PositionedView, this.options);
    this.container = $(this.containerTemplate).hide();
    if (this.options.containerClass) {
      this.container.addClass(this.options.containerClass);
    }
    this.positionTarget = $(this.options.positionTarget);
    this.container.on('click', function(event) {
      return event.stopPropagation();
    });
  }

  PositionedView.prototype.closeIfClickedOutside = function(clickTarget) {
    clickTarget = $(clickTarget);
    return $('body').on(
      'click',
      function(_this) {
        return function(event) {
          if (clickTarget[0] !== event.target && clickTarget.has(event.target).length === 0) {
            return _this.hide();
          }
        };
      }(this)
    );
  };

  /*
   * Render the the view by appending it to a container
   */
  PositionedView.prototype.appendTo = function(selector) {
    return $(selector).append(this.container);
  };

  PositionedView.prototype.toggle = function() {
    if (this.isVisible()) {
      return this.hide();
    } else {
      return this.show();
    }
  };

  PositionedView.prototype.show = function() {
    /*
     * Reset rendering position
     */
    this.renderPosition = null;
    this.container.show();
    return this.reposition();
  };

  PositionedView.prototype.hide = function() {
    return this.container.hide();
  };

  PositionedView.prototype.isVisible = function() {
    return this.container.is(':visible');
  };

  PositionedView.prototype.reposition = function() {
    var height, heightAbove, left, rightPos, sTop, tHeight, tOffset, tWidth, top, wWidth, width;
    if (!(this.positionTarget.length > 0)) {
      return;
    }

    /*
     * Width/height of the datepicker container
     */
    width = this.container.width();
    height = this.container.height();

    /*
     * Offset of the position target reletave to the page
     */
    tOffset = this.positionTarget.offset();

    /*
     * Width/height of the position target
     */
    tWidth = this.positionTarget.outerWidth();
    tHeight = this.positionTarget.outerHeight();

    /*
     * Window height and scroll position
     * wHeight = $(window).height()
     */
    wWidth = $(window).width();
    sTop = $(window).scrollTop();

    /*
     * Calculate available viewport height above/below the target
     */
    heightAbove = tOffset.top - sTop;

    /* heightBelow = wHeight + sTop - tOffset.top */
    /*
     * Determine whether to place the datepicker above or below the target element.
     * If there is enough window height above element to render the container, then we put it
     * above. If there is not enough (i.e. it would be partially hidden if rendered above), then
     * we render it below the target.
     */
    if (
      this.renderPosition !== 'below' && (this.renderPosition === 'above' || heightAbove < height)
    ) {
      top = tOffset.top + tHeight + this.options.positionPadding;
      this.renderPosition = 'above';
    } else {
      /*
       * Render above element
       */
      top = tOffset.top - height - this.options.positionPadding;
      this.renderPosition = 'below';
    }

    /*
     * Left position is based off the container width and the position target width/position
     */
    left = tOffset.left + parseInt(tWidth / 2, 10) - parseInt(width / 2, 10);

    /*
     * Don't let it render outside of the window viewport on the right side.
     * Also force minimum padding, and shift the position left until it fits properly.
     */
    rightPos = left + width;
    if (rightPos > wWidth - this.options.windowRightPadding) {
      left -= rightPos - wWidth + this.options.windowRightPadding;
    }

    /*
     * Update the position of the datepicker container
     */
    return this.container.css({ 'top': top + 'px', 'left': left + 'px' });
  };

  return PositionedView;
}();

module.exports = PositionedView;
