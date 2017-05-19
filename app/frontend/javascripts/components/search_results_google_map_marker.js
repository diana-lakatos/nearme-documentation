/* global google */
var SearchResultsGoogleMapMarker, urlUtil;

urlUtil = require('../lib/utils/url');

SearchResultsGoogleMapMarker = function() {
  function SearchResultsGoogleMapMarker() {}

  SearchResultsGoogleMapMarker.markerOptions = {
    hover: {
      image: {
        url: urlUtil.assetUrl('markers/marker-hover.png'),
        size: new google.maps.Size(20, 29),
        scaledSize: new google.maps.Size(20, 29),
        origin: new google.maps.Point(0, 0),
        anchor: new google.maps.Point(10, 29)
      }
    },
    'default': {
      image: {
        url: urlUtil.assetUrl('markers/marker-default.png'),
        size: new google.maps.Size(20, 29),
        scaledSize: new google.maps.Size(20, 29),
        origin: new google.maps.Point(0, 0),
        anchor: new google.maps.Point(10, 29)
      }
    }
  };

  SearchResultsGoogleMapMarker.getMarkerOptions = function() {
    return this.markerOptions;
  };

  return SearchResultsGoogleMapMarker;
}();

module.exports = SearchResultsGoogleMapMarker;
