/* global google */
var AddressField, AddressFieldController, SmartGoogleMap;

AddressField = require('./address_field');

SmartGoogleMap = require('./smart_google_map');

AddressFieldController = function() {
  function AddressFieldController(container) {
    this.container = $(container);
    this.setupMap();
    this.address = new AddressField(this.container.find('[data-behavior="address-autocomplete"]'));
    this.disableEnterFor(this.container.find('[data-behavior="address-autocomplete"]'));
    this.address.onLocate(
      function(_this) {
        return function(lat, lng) {
          var latlng;
          latlng = new google.maps.LatLng(lat, lng);
          _this.map.marker.setPosition(latlng);
          _this.mapContainer.show();
          google.maps.event.trigger(_this.map.map, 'resize');
          return _this.map.map.setCenter(latlng);
        };
      }(this)
    );
    this.address.bump();
  }

  AddressFieldController.prototype.setupMap = function() {
    this.mapContainer = this.container.find('.map');
    this.map = { map: null, markers: [] };
    this.map.map = SmartGoogleMap.createMap(this.mapContainer.find('.map-container')[0], {
      zoom: 16,
      mapTypeControl: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    this.map.marker = new google.maps.Marker({
      map: this.map.map,
      icon: this.mapContainer.attr('data-marker'),
      draggable: true
    });

    /*
     * When the marker is dragged, update the lat/lng form position
     */
    return google.maps.event.addListener(
      this.map.marker,
      'dragend',
      function(_this) {
        return function() {
          var position;
          position = _this.map.marker.getPosition();
          return _this.address.markerMoved(position.lat(), position.lng());
        };
      }(this)
    );
  };

  AddressFieldController.prototype.disableEnterFor = function(field) {
    return $(field).keydown(function(event) {
      if (event.keyCode === 13) {
        event.preventDefault();
        return false;
      }
    });
  };

  return AddressFieldController;
}();

module.exports = AddressFieldController;
