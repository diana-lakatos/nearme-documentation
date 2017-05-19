/* global google */
var SmartGoogleMap;

SmartGoogleMap = function() {
  function SmartGoogleMap() {}

  SmartGoogleMap.createMap = function(container1, googleMapOptions, configuration) {
    var map;
    SmartGoogleMap.container = container1;
    SmartGoogleMap.googleMapOptions = googleMapOptions;
    SmartGoogleMap.configuration = configuration != null ? configuration : void 0;
    map = new google.maps.Map(SmartGoogleMap.container, SmartGoogleMap.googleMapOptions);
    if (!SmartGoogleMap.shouldBeIgnored('draggable')) {
      SmartGoogleMap.setDraggable(false, map);
      SmartGoogleMap.bindEvents(map);
    }
    if (!SmartGoogleMap.shouldBeIgnored('styles')) {
      SmartGoogleMap.setStyles(map);
    }
    return map;
  };

  SmartGoogleMap.bindEvents = function(map) {
    google.maps.event.addListener(
      map,
      'click',
      function(_this) {
        return function() {
          return _this.setDraggable(true, map);
        };
      }(this)
    );
    return $(document).mouseup(
      function(_this) {
        return function(e) {
          var container;
          container = $(map.getDiv());
          if (container.has(e.target).length === 0) {
            return _this.setDraggable(false, map);
          }
        };
      }(this)
    );
  };

  SmartGoogleMap.shouldBeIgnored = function(feature) {
    return SmartGoogleMap.configuration && SmartGoogleMap.configuration.exclude &&
      SmartGoogleMap.configuration.exclude.indexOf(feature) > -1;
  };

  SmartGoogleMap.setStyles = function(map) {
    var options;
    options = {
      /*
       * JSON generated using: http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html
       */
      styles: [
        {
          'featureType': 'water',
          'elementType': 'geometry.fill',
          'stylers': [ { 'color': '#457cbc' } ]
        },
        {
          'featureType': 'water',
          'elementType': 'labels.text.stroke',
          'stylers': [ { 'weight': 0.1 }, { 'color': '#d0bfe0' }, { 'visibility': 'off' } ]
        },
        {
          'featureType': 'water',
          'elementType': 'labels.text.fill',
          'stylers': [ { 'visibility': 'on' }, { 'lightness': 5 }, { 'color': '#e6e4e7' } ]
        },
        {
          'featureType': 'poi.business',
          'elementType': 'labels',
          'stylers': [ { 'visibility': 'simplified' } ]
        },
        {
          'featureType': 'road.arterial',
          'elementType': 'geometry.fill',
          'stylers': [ { 'visibility': 'on' }, { 'color': '#f6edbc' } ]
        },
        {
          'featureType': 'road.arterial',
          'elementType': 'labels.text.stroke',
          'stylers': [ { 'visibility': 'off' } ]
        },
        {
          'featureType': 'poi.park',
          'elementType': 'labels.text.stroke',
          'stylers': [ { 'visibility': 'off' } ]
        },
        { 'elementType': 'labels.text.stroke', 'stylers': [ { 'visibility': 'off' } ] },
        {
          'featureType': 'poi.school',
          'elementType': 'labels',
          'stylers': [ { 'weight': 0.1 }, { 'visibility': 'simplified' } ]
        },
        {
          'featureType': 'poi.medical',
          'elementType': 'labels',
          'stylers': [ { 'visibility': 'simplified' } ]
        },
        { 'featureType': 'poi', 'elementType': 'geometry.fill' },
        { 'featureType': 'poi.business', 'stylers': [ { 'visibility': 'off' } ] }
      ]
    };
    return map.setOptions(options);
  };

  SmartGoogleMap.setDraggable = function(draggable, map) {
    var options;
    if (draggable) {
      $(map.getDiv()).parent().addClass('map-active');
    } else {
      $(map.getDiv()).parent().removeClass('map-active');
    }
    options = { draggable: draggable, scrollwheel: draggable };
    return map.setOptions(options);
  };

  return SmartGoogleMap;
}();

module.exports = SmartGoogleMap;
