urlUtil = require('../lib/utils/url')

module.exports = class SearchResultsGoogleMapMarker
  @markerOptions:
    hover:
      image:
        url: urlUtil.assetUrl('markers/marker-hover.png')
        size: new google.maps.Size(20,29)
        scaledSize: new google.maps.Size(20,29)
        origin: new google.maps.Point(0,0)
        anchor: new google.maps.Point(10, 29)

    default:
      image:
        url: urlUtil.assetUrl('markers/marker-default.png')
        size: new google.maps.Size(20,29)
        scaledSize: new google.maps.Size(20,29)
        origin: new google.maps.Point(0,0)
        anchor: new google.maps.Point(10, 29)

  @getMarkerOptions: ->
    @markerOptions
