/* global google */
var SearchResultsGoogleMapController, SmartGoogleMap;

SmartGoogleMap = require('../../components/smart_google_map');

/*
 * Controller for Adding JS for each search result in 'list' view
 *
 */
SearchResultsGoogleMapController = function() {
  function SearchResultsGoogleMapController(container, googleMapWrapper) {
    this.container = container;
    this.googleMapWrapper = googleMapWrapper;
    if (this.googleMapWrapper.length > 0) {
      this.googleMapWrapper = this.googleMapWrapper.clone();
      this.map = this.initializeGoogleMap();
      this.setBindings();
    }
  }

  SearchResultsGoogleMapController.prototype.setBindings = function() {
    this.container.on(
      'mouseenter',
      '.photo-container',
      function(_this) {
        return function(event) {
          var element, elementsGoogleMapWrapper, latlng;
          element = $(event.target).closest('.listing');
          elementsGoogleMapWrapper = element.find('.listing-google-map');
          _this.googleMapWrapper.appendTo(elementsGoogleMapWrapper);
          latlng = new google.maps.LatLng(element.data('latitude'), element.data('longitude'));
          _this.map.marker.setPosition(latlng);
          element.find('.listing-google-map-wrapper').show();
          google.maps.event.trigger(_this.map, 'resize');
          return _this.map.setCenter(_this.map.marker.getPosition());
        };
      }(this)
    );
    return this.container.on('mouseleave', '.photo-container', function(event) {
      var element;
      element = $(event.target).closest('.listing');
      return element.find('.listing-google-map-wrapper').hide();
    });
  };

  SearchResultsGoogleMapController.prototype.initializeGoogleMap = function() {
    var map;
    map = SmartGoogleMap.createMap(this.googleMapWrapper.get(0), {
      zoom: 14,
      zoomControl: true,
      mapTypeControl: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    map.marker = new google.maps.Marker({
      map: map,
      icon: this.googleMapWrapper.attr('data-marker'),
      draggable: false
    });
    return map;
  };

  return SearchResultsGoogleMapController;
}();

module.exports = SearchResultsGoogleMapController;
