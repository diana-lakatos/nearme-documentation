SmartGoogleMap = require('../../components/smart_google_map')

# Controller for Adding JS for each search result in 'list' view
#
module.exports = class SearchResultController

  @googleMapContainerWrapperClass = '.listing-google-map-wrapper'
  @googleMapContainerClass = '.listing-google-map'

  @handleResult: (result) ->
    map = @initializeGoogleMap(result)
    @bindMapToResult(map, result)
    @bindToolTip(result)

  @bindMapToResult: (map, result) ->
    if result.find('.photo-container.without-photos').length > 0
      result.find(@googleMapContainerWrapperClass).show()
      google.maps.event.trigger(map, "resize")
      map.setCenter(map.marker.getPosition())
    else
      result.find('.photo-container').bind 'mouseenter', (event) =>
        result.find(@googleMapContainerWrapperClass).show()
        google.maps.event.trigger(map, "resize")
        map.setCenter(map.marker.getPosition())

      result.find('.photo-container').bind 'mouseleave', (event) =>
        $(event.target).closest('article.listing').find(@googleMapContainerWrapperClass).hide()

  @bindToolTip: (result) ->
    result.find('.connections').tooltip(html: true, placement: 'top')

  @initializeGoogleMap: (result) ->
    mapContainer = result.find(@googleMapContainerClass).eq(0)
    # .get(0) is to get antive dom element instead of jquery object, otherwise error will be raised
    map = SmartGoogleMap.createMap(mapContainer.get(0), {
      zoom: 14,
      zoomControl: true,
      mapTypeControl: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })

    map.marker = new google.maps.Marker({
      map: map,
      icon: mapContainer.attr("data-marker"),
      draggable: false
    })

    latlng = new google.maps.LatLng(result.data('latitude'), result.data('longitude'))
    map.marker.setPosition(latlng)
    map.setCenter(map.marker.getPosition())

    map
