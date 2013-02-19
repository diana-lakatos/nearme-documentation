# Encapsulates the map behaviour for the serach results
class Search.Map
  asEvented.call(Map.prototype)

  # Custom marker definitions
  # Generated from: http://powerhut.co.uk/googlemaps/custom_markers.php
  MARKERS =
    hover:
      image: new google.maps.MarkerImage(
        '/assets/google-maps/marker-images/hover.png',
        new google.maps.Size(20,28),
        new google.maps.Point(0,0),
        new google.maps.Point(10,28)
      )

      shadow: new google.maps.MarkerImage(
        '/assets/google-maps/marker-images/hover-shadow.png',
        new google.maps.Size(38,28),
        new google.maps.Point(0,0),
        new google.maps.Point(10,28)
      )

      shape:
        coord: [14,0,15,1,16,2,17,3,18,4,18,5,19,6,19,7,19,8,19,9,19,10,19,11,19,12,18,13,18,14,17,15,17,16,16,17,16,18,15,19,15,20,14,21,13,22,13,23,12,24,12,25,11,26,10,27,8,27,7,26,7,25,6,24,6,23,5,22,5,21,4,20,3,19,3,18,2,17,2,16,1,15,1,14,0,13,0,12,0,11,0,10,0,9,0,8,0,7,0,6,0,5,1,4,1,3,2,2,3,1,5,0,14,0]
        type: 'poly'

    default:
      image: new google.maps.MarkerImage(
        '/assets/google-maps/marker-images/default.png',
        new google.maps.Size(20,28),
        new google.maps.Point(0,0),
        new google.maps.Point(10,28)
      )

      shadow: new google.maps.MarkerImage(
        '/assets/google-maps/marker-images/default-shadow.png',
        new google.maps.Size(38,28),
        new google.maps.Point(0,0),
        new google.maps.Point(10,28)
      )

      shape:
        coord: [14,0,15,1,16,2,17,3,18,4,18,5,19,6,19,7,19,8,19,9,19,10,19,11,19,12,18,13,18,14,17,15,17,16,16,17,16,18,15,19,15,20,14,21,13,22,13,23,12,24,12,25,11,26,10,27,8,27,7,26,7,25,6,24,6,23,5,22,5,21,4,20,3,19,3,18,2,17,2,16,1,15,1,14,0,13,0,12,0,11,0,10,0,9,0,8,0,7,0,6,0,5,1,4,1,3,2,2,3,1,5,0,14,0]
        type: 'poly'

  constructor: (@container) ->
    @initializeGoogleMap()
    @bindEvents()

  initializeGoogleMap: ->
    @googleMap = new google.maps.Map(@container, {
      zoom: 8,
      minZoom: 4,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      disableDefaultUI: true
      zoomControl: true,
      scrollwheel: false
    })

    # Info window pops over and contains details for each marker/listing
    @infoWindow = new google.maps.InfoWindow()
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

  # Clears any plotted listings and resets the map
  resetMapMarkers: ->
    if @markers
      for listingId, marker of @markers
        marker.setMap(null)

    @markers = {}
    @initializeListingBounds()

  initializeListingBounds: ->
    @bounds = new google.maps.LatLngBounds()
    for listingId, marker of @markers
      @bounds.extend(marker.getPosition())

  removeListingsOutOfMapBounds: ->
    mapBounds = @googleMap.getBounds()

    for listingId, marker of @markers
      latLng = marker.getPosition()
      unless mapBounds.contains(latLng)
        marker.setMap(null)
        delete @markers[listingId]

    # Need to refresh the map bounds object since we've
    # removed listings.
    @initializeListingBounds()

  plotListings: (listings) ->
    @plotListing(listing) for listing in listings

  # Only plot a listing if it fits within the map bounds.
  # Returns whether or not a listing was plotted.
  plotListingIfInMapBounds: (listing) ->
    latLng = listing.latLng()
    if @googleMap.getBounds().contains(latLng)
      @plotListing(listing)
      true
    else
      false

  plotListing: (listing) ->
    # Don't re-plot the same listing
    return if @markers[listing.id()]

    marker = new google.maps.Marker(
      position: listing.latLng(),
      map:      @googleMap,
      title:    listing.name(),
      visible:  false,
      icon: MARKERS.default.image,
      shadow: MARKERS.default.shadow,
      shape: MARKERS.default.shape
    )
    @markers[listing.id()] = marker
    @bounds.extend(listing.latLng())

    marker.setAnimation(google.maps.Animation.DROP)
    marker.setVisible(true)

    # Bind the event for showing the info details on click
    google.maps.event.addListener marker, 'click', =>
      @showInfoWindowForListing(listing)

    google.maps.event.addListener marker, 'mouseover', =>
      @focusMarker(marker)
      @trigger 'mouseoverListingMarker', listing

    google.maps.event.addListener marker, 'mouseout', =>
      @blurMarker(marker)
      @trigger 'mouseoutListingMarker', listing

  focusMarker: (marker) ->
    marker.setOptions(
      icon: MARKERS.hover.image,
      shadow: MARKERS.hover.shadow,
      shape: MARKERS.hover.shape
    )

  blurMarker: (marker) ->
    marker.setOptions(
      icon: MARKERS.default.image,
      shadow: MARKERS.default.shadow,
      shape: MARKERS.default.shape
    )

  focusListingMarker: (listing) ->
    marker = @markers[listing.id()]
    @focusMarker(marker) if marker

  blurListingMarker: (listing) ->
    marker = @markers[listing.id()]
    @blurMarker(marker) if marker

  fitBounds: ->
    @googleMap.fitBounds(@bounds) unless @bounds.isEmpty()

  # Return an array of [nx, ny, sx, sy] coordinates
  getBoundsArray: ->
    bounds = @googleMap.getBounds()
    ne = bounds.getNorthEast()
    sw = bounds.getSouthWest()
    [ne.lat(), ne.lng(), sw.lat(), sw.lng()]

  showInfoWindowForListing: (listing) ->
    @infoWindow.setContent(listing.popupContent())
    if marker = @markers[listing.id()]
      @infoWindow.open(@googleMap, marker)
