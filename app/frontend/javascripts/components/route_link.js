/* global google */
var RouteLink,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

RouteLink = function() {
  function RouteLink(element) {
    this.element = element;
    this.geocode = bind(this.geocode, this);
    this.locate();
  }

  RouteLink.prototype.locate = function() {
    if (!Modernizr.geolocation) {
      return;
    }
    return navigator.geolocation.getCurrentPosition(
      function(_this) {
        return function(position) {
          _this.latitude = position.coords.latitude;
          _this.longitude = position.coords.longitude;
          return _this.geocode();
        };
      }(this)
    );
  };

  RouteLink.prototype.geocode = function() {
    var geocoder, latLng;
    geocoder = new google.maps.Geocoder();
    latLng = new google.maps.LatLng(this.latitude, this.longitude);
    return geocoder.geocode(
      { latLng: latLng },
      function(_this) {
        return function(results, status) {
          if (status === google.maps.GeocoderStatus.OK) {
            _this.source = results[0].formatted_address;
            return _this.rewriteRouteLink();
          }
        };
      }(this)
    );
  };

  RouteLink.prototype.rewriteRouteLink = function() {
    var destination, link, source;
    destination = this.element.data('destination');
    source = this.source;
    link = '//maps.google.com/?daddr=' + destination + '&saddr=' + source;
    return this.element.attr('href', link);
  };

  return RouteLink;
}();

module.exports = RouteLink;
