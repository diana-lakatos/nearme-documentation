/* global google */
var GoogleMapPopover, InfoBox, asEvented;

require('../../vendor/jquery.hasScrollBar');

asEvented = require('asevented');

InfoBox = require('exports?InfoBox!../../vendor/infobox');

/*
 * Wrapper class for our custom Google Map popover dialog boxes.
 */
GoogleMapPopover = function() {
  asEvented.apply(GoogleMapPopover.prototype);

  GoogleMapPopover.prototype.defaultOptions = {
    boxClass: 'google-map-popover',
    pixelOffset: null,
    maxWidth: 0,
    boxStyle: { width: '288px' },
    alignBottom: true,
    contentWrapper: '<div>\n  <div class="google-map-popover-content"></div>\n  <em class="arrow-border"></em>\n  <em class="arrow"></em>\n</div>'
  };

  function GoogleMapPopover(options) {
    this.options = $.extend(this.getDefaultOptions(), options);
    this.infoBox = new InfoBox({
      maxWidth: this.options.maxWidth,
      boxClass: this.options.boxClass,
      pixelOffset: this.options.pixelOffset,
      boxStyle: this.options.boxStyle,
      alignBottom: this.options.alignBottom,
      content: '',
      closeBoxURL: '',
      infoBoxClearance: new google.maps.Size(1, 1)
    });
  }

  GoogleMapPopover.prototype.close = function() {
    this.infoBox.close();
    return this.trigger('closed');
  };

  GoogleMapPopover.prototype.open = function(map, position) {
    this.close();
    this.infoBox.open(map, position);
    return this.trigger('opened');
  };

  GoogleMapPopover.prototype.setContent = function(content) {
    return this.infoBox.setContent(this.wrapContent(content));
  };

  GoogleMapPopover.prototype.setError = function(content) {
    return this.infoBox.setContent(
      this.wrapContent("<div class='popover-error'><span class=''>" + content + '</span></div>')
    );
  };

  GoogleMapPopover.prototype.markAsBeingLoaded = function() {
    return this.infoBox.setContent(
      this.wrapContent(
        '<div class="popover-loading"><img src="' + $('.loading').find('img').attr('src') +
          '"><br /><span>Loading...</span></div>'
      )
    );
  };

  GoogleMapPopover.prototype.getDefaultOptions = function() {
    return $.extend({}, this.defaultOptions, { pixelOffset: new google.maps.Size(-144, -40) });
  };

  GoogleMapPopover.prototype.wrapContent = function(content) {
    /*
     * We need to wrap the close button click to close
     */
    var wrapper;
    wrapper = $(this.options.contentWrapper);
    wrapper.find('.google-map-popover-content').html(content);
    wrapper.find('.listing-sibling').on('click', function() {
      return location.href = $(this).attr('data-link');
    });
    wrapper.find('h4.location-title:first-child').append('<a href="" class="close ico-close"></a>');
    wrapper.find('.close').on(
      'click',
      function(_this) {
        return function(event) {
          event.preventDefault();
          return _this.close();
        };
      }(this)
    );
    if (wrapper.find('.google-map-popover-content').length > 0) {
      if (wrapper.find('.google-map-popover-content').hasScrollBar()) {
        $('.' + this.options.boxClass).addClass('with-scrollbar');
      } else {
        $('.' + this.options.boxClass).removeClass('with-scrollbar');
      }
    }
    return wrapper[0];
  };

  return GoogleMapPopover;
}();

module.exports = GoogleMapPopover;
