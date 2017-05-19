/* global google */
var LocationField;

LocationField = function() {
  function LocationField(el) {
    this.root = $(el);
    this.input = this.root.find('input');
    this.map = this.root.find('.map');
    this.init();
    if (!this.input.val()) {
      this.getCurrentPosition();
    }
  }

  LocationField.prototype.onFindPositionSuccess = function(position) {
    var geocoder, input, latlng;
    latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
    input = this.input;
    geocoder = new google.maps.Geocoder();
    return geocoder.geocode({ 'location': latlng }, function(results, status) {
      if (!(status === google.maps.GeocoderStatus.OK && results[1])) {
        return;
      }
      return input.geocomplete('find', results[1].formatted_address);
    });
  };

  LocationField.prototype.onFindPositionError = function(msg) {
    return console.log(msg);
  };

  LocationField.prototype.getCurrentPosition = function() {
    if (!navigator.geolocation) {
      return;
    }
    return navigator.geolocation.getCurrentPosition(
      this.onFindPositionSuccess.bind(this),
      this.onFindPositionError
    );
  };

  LocationField.prototype.init = function() {
    this.input.geocomplete({
      map: this.map.get(0),
      mapOptions: {
        disableDefaultUI: true,
        disableDoubleClickZoom: true,
        minZoom: 9,
        maxZoom: 9,
        draggable: false,
        panControl: false
      }
    });
    this.input.on(
      'geocode:result',
      $.proxy(function() {
        return this.root.addClass('is-touched');
      }),
      this
    );
    this.input.on('blur', function() {
      return $(this).trigger('geocode');
    });
    if (this.input.val()) {
      return this.input.trigger('geocode');
    }
  };

  LocationField.initialize = function() {
    if (!(window.google && window.google.maps)) {
      return;
    }
    return $('.form-a .location').each(function() {
      return new LocationField(this);
    });
  };

  return LocationField;
}();

module.exports = LocationField;
