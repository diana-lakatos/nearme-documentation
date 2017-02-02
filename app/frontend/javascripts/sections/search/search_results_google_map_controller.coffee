SmartGoogleMap = require('../../components/smart_google_map')

# Controller for Adding JS for each search result in 'list' view
#

module.exports = class SearchResultsGoogleMapController

  constructor: (@container, @googleMapWrapper) ->
    if @googleMapWrapper.length > 0
      @googleMapWrapper = @googleMapWrapper.clone()
      @map = @initializeGoogleMap()
      @setBindings()

  setBindings: ->
    @container.on 'mouseenter', '.photo-container', (event) =>
      element = $(event.target).closest('.listing')
      elementsGoogleMapWrapper = element.find('.listing-google-map')
      @googleMapWrapper.appendTo(elementsGoogleMapWrapper)
      latlng = new google.maps.LatLng(element.data('latitude'), element.data('longitude'))
      @map.marker.setPosition(latlng)
      element.find('.listing-google-map-wrapper').show()
      google.maps.event.trigger(@map, "resize")
      @map.setCenter(@map.marker.getPosition())

    @container.on 'mouseleave', '.photo-container', (event) ->
      element = $(event.target).closest('.listing')
      elementsGoogleMapWrapper = element.find('.listing-google-map')
      element.find('.listing-google-map-wrapper').hide()

  initializeGoogleMap: ->
    map = SmartGoogleMap.createMap(@googleMapWrapper.get(0), {
      zoom: 14,
      zoomControl: true,
      mapTypeControl: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })

    map.marker = new google.maps.Marker({
      map: map,
      icon: @googleMapWrapper.attr("data-marker"),
      draggable: false
    })

    map
