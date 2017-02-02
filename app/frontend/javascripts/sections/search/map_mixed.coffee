SearchMap = require('./map')
asEvented = require('asevented')
SearchResultsGoogleMapMarker = require('../../components/search_results_google_map_marker')
SmartGoogleMap = require('../../components/smart_google_map')

# Encapsulates the map behaviour for the serach results

module.exports = class MapMixed extends SearchMap
  asEvented.call @prototype

  GOOGLE_MAP_OPTIONS =
    zoom: 12,
    minZoom: 2,
    maxZoom: 18,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    disableDefaultUI: true,
    zoomControl: true

  constructor: (@container, controller) ->
    super

  initializeGoogleMap: ->
    @googleMap = SmartGoogleMap.createMap(@container, GOOGLE_MAP_OPTIONS, { exclude: ['draggable'] })
    @resetMapMarkers()

  bindEvents: ->
    # Ensure the map is notified of window resize, and positioning adjusted.
    $(window).resize =>
      google.maps.event.trigger(@googleMap, 'resize')
      # NB: We don't update the map bounds here as the mobile UI's seemingly do
      # minor dimension changes during scrolling resulting in poor UX if we modify
      # the map bounds which triggers viewportChanged callbacks.

    google.maps.event.addListener @googleMap, 'dragend', =>
      @trigger 'viewportChanged'

    google.maps.event.addListener @googleMap, 'zoom_changed', =>
      @trigger 'viewportChanged'

    google.maps.event.addListener @googleMap, 'click', (e) =>
      @trigger 'click'

    null


  plotListing: (listing) ->
    # Don't re-plot the same listing
    return if @markers[listing.id()]

    marker = new google.maps.Marker(
      position: listing.latLng(),
      map:      @googleMap,
      title:    listing.name(),
      visible:  false,
      shadow: null,
      icon: SearchResultsGoogleMapMarker.getMarkerOptions().default.image
    )
    @markers[listing.id()] = marker
    @listings[listing.id()] = listing
    @bounds.extend(listing.latLng())

    google.maps.event.addListener marker, 'mouseover', ->
      marker.setIcon(SearchResultsGoogleMapMarker.getMarkerOptions().hover.image)

    google.maps.event.addListener marker, 'mouseout', ->
      marker.setIcon(SearchResultsGoogleMapMarker.getMarkerOptions().default.image)

    google.maps.event.addListener marker, 'click', =>
      @search_controller.markerClicked(marker)

    marker.setVisible(true)


  setZoom: (zoomLevel) ->
    @googleMap.setZoom(zoomLevel)
