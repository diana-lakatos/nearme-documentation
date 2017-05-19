/* global google */
var SearchResultController, SmartGoogleMap;

SmartGoogleMap = require('../../components/smart_google_map');

/*
 * Controller for Adding JS for each search result in 'list' view
 *
 */
SearchResultController = function() {
  function SearchResultController() {}

  SearchResultController.googleMapContainerWrapperClass = '.listing-google-map-wrapper';

  SearchResultController.googleMapContainerClass = '.listing-google-map';

  SearchResultController.handleResult = function(result) {
    var map;
    map = this.initializeGoogleMap(result);
    this.bindMapToResult(map, result);
    return this.bindToolTip(result);
  };

  SearchResultController.bindMapToResult = function(map, result) {
    if (result.find('.photo-container.without-photos').length > 0) {
      result.find(this.googleMapContainerWrapperClass).show();
      google.maps.event.trigger(map, 'resize');
      return map.setCenter(map.marker.getPosition());
    } else {
      result.find('.photo-container').bind(
        'mouseenter',
        function(_this) {
          return function() {
            result.find(_this.googleMapContainerWrapperClass).show();
            google.maps.event.trigger(map, 'resize');
            return map.setCenter(map.marker.getPosition());
          };
        }(this)
      );
      return result.find('.photo-container').bind(
        'mouseleave',
        function(_this) {
          return function(event) {
            return $(event.target)
              .closest('article.listing')
              .find(_this.googleMapContainerWrapperClass)
              .hide();
          };
        }(this)
      );
    }
  };

  SearchResultController.bindToolTip = function(result) {
    return result.find('.connections').tooltip({ html: true, placement: 'top' });
  };

  SearchResultController.initializeGoogleMap = function(result) {
    var latlng, map, mapContainer;
    mapContainer = result.find(this.googleMapContainerClass).eq(0);

    /*
     * .get(0) is to get antive dom element instead of jquery object, otherwise error will be raised
     */
    map = SmartGoogleMap.createMap(mapContainer.get(0), {
      zoom: 14,
      zoomControl: true,
      mapTypeControl: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    map.marker = new google.maps.Marker({
      map: map,
      icon: mapContainer.attr('data-marker'),
      draggable: false
    });
    latlng = new google.maps.LatLng(result.data('latitude'), result.data('longitude'));
    map.marker.setPosition(latlng);
    map.setCenter(map.marker.getPosition());
    return map;
  };

  return SearchResultController;
}();

module.exports = SearchResultController;
