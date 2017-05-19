/* global google */
var MapMixed,
  SearchMap,
  SearchResultsGoogleMapMarker,
  SmartGoogleMap,
  asEvented,
  extend = function(child, parent) {
    for (var key in parent) {
      if (hasProp.call(parent, key))
        child[key] = parent[key];
    }
    function ctor() {
      this.constructor = child;
    }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype;
    return child;
  },
  hasProp = {}.hasOwnProperty;

SearchMap = require('./map');

asEvented = require('asevented');

SearchResultsGoogleMapMarker = require('../../components/search_results_google_map_marker');

SmartGoogleMap = require('../../components/smart_google_map');

/*
 * Encapsulates the map behaviour for the serach results
 */
MapMixed = function(superClass) {
  var GOOGLE_MAP_OPTIONS;

  extend(MapMixed, superClass);

  asEvented.call(MapMixed.prototype);

  GOOGLE_MAP_OPTIONS = {
    zoom: 12,
    minZoom: 2,
    maxZoom: 18,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    disableDefaultUI: true,
    zoomControl: true
  };

  function MapMixed(container, controller) {
    this.container = container;
    MapMixed.__super__.constructor.call(this, this.container, controller);
  }

  MapMixed.prototype.initializeGoogleMap = function() {
    this.googleMap = SmartGoogleMap.createMap(this.container, GOOGLE_MAP_OPTIONS, {
      exclude: [ 'draggable' ]
    });
    return this.resetMapMarkers();
  };

  MapMixed.prototype.bindEvents = function() {
    /*
     * Ensure the map is notified of window resize, and positioning adjusted.
     */
    $(window).resize(
      function(_this) {
        return function() {
          return google.maps.event.trigger(_this.googleMap, 'resize');
          /*
         * NB: We don't update the map bounds here as the mobile UI's seemingly do
         * minor dimension changes during scrolling resulting in poor UX if we modify
         * the map bounds which triggers viewportChanged callbacks.
         */
        };
      }(this)
    );
    google.maps.event.addListener(
      this.googleMap,
      'dragend',
      function(_this) {
        return function() {
          return _this.trigger('viewportChanged');
        };
      }(this)
    );
    google.maps.event.addListener(
      this.googleMap,
      'zoom_changed',
      function(_this) {
        return function() {
          return _this.trigger('viewportChanged');
        };
      }(this)
    );
    google.maps.event.addListener(
      this.googleMap,
      'click',
      function(_this) {
        return function() {
          return _this.trigger('click');
        };
      }(this)
    );
    return null;
  };

  MapMixed.prototype.plotListing = function(listing) {
    /*
     * Don't re-plot the same listing
     */
    var marker;
    if (this.markers[listing.id()]) {
      return;
    }
    marker = new google.maps.Marker({
      position: listing.latLng(),
      map: this.googleMap,
      title: listing.name(),
      visible: false,
      shadow: null,
      icon: SearchResultsGoogleMapMarker.getMarkerOptions()['default'].image
    });
    this.markers[listing.id()] = marker;
    this.listings[listing.id()] = listing;
    this.bounds.extend(listing.latLng());
    google.maps.event.addListener(marker, 'mouseover', function() {
      return marker.setIcon(SearchResultsGoogleMapMarker.getMarkerOptions().hover.image);
    });
    google.maps.event.addListener(marker, 'mouseout', function() {
      return marker.setIcon(SearchResultsGoogleMapMarker.getMarkerOptions()['default'].image);
    });
    google.maps.event.addListener(
      marker,
      'click',
      function(_this) {
        return function() {
          return _this.search_controller.markerClicked(marker);
        };
      }(this)
    );
    return marker.setVisible(true);
  };

  MapMixed.prototype.setZoom = function(zoomLevel) {
    return this.googleMap.setZoom(zoomLevel);
  };

  return MapMixed;
}(SearchMap);

module.exports = MapMixed;
