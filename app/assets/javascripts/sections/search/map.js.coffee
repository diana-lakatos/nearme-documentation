# Encapsulates the map behaviour for the serach results
class Search.Map
  asEvented.call(Map.prototype)

  # Custom marker definitions
  # Generated from: http://powerhut.co.uk/googlemaps/custom_markers.php
  MARKERS =
    hover:
      image: new google.maps.MarkerImage(
        '/assets/google-maps/marker-images/hover-2x.png',
        new google.maps.Size(40,57),
        new google.maps.Point(0,0),
        new google.maps.Point(10,29),
        new google.maps.Size(20,29)
      )

      shape:
        coord: [14,0,15,1,16,2,17,3,18,4,18,5,19,6,19,7,19,8,19,9,19,10,19,11,19,12,19,13,18,14,18,15,17,16,17,17,16,18,16,19,15,20,14,21,14,22,13,23,13,24,12,25,11,26,11,27,8,27,7,26,7,25,6,24,6,23,5,22,4,21,4,20,3,19,3,18,2,17,2,16,1,15,0,14,0,13,0,12,0,11,0,10,0,9,0,8,0,7,0,6,0,5,1,4,1,3,2,2,3,1,5,0,14,0],
        type: 'poly'

    default:
      image: new google.maps.MarkerImage(
        '/assets/google-maps/marker-images/default-2x.png',
        new google.maps.Size(40,57),
        new google.maps.Point(0,0),
        new google.maps.Point(10,29),
        new google.maps.Size(20,29)
      )

      shape:
        coord: [14,0,15,1,16,2,17,3,18,4,18,5,19,6,19,7,19,8,19,9,19,10,19,11,19,12,19,13,18,14,18,15,17,16,17,17,16,18,16,19,15,20,14,21,14,22,13,23,13,24,12,25,11,26,11,27,8,27,7,26,7,25,6,24,6,23,5,22,4,21,4,20,3,19,3,18,2,17,2,16,1,15,0,14,0,13,0,12,0,11,0,10,0,9,0,8,0,7,0,6,0,5,1,4,1,3,2,2,3,1,5,0,14,0]
        type: 'poly'

  constructor: (@container) ->
    @initializeGoogleMap()
    @bindEvents()
    @cacheMarkers()

  initializeGoogleMap: ->
    @googleMap = SmartGoogleMap.createMap(@container, {
      zoom: 8,
      minZoom: 4,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      disableDefaultUI: true
      zoomControl: true,
    })

    # Info window pops over and contains details for each marker/listing
    @popover = new GoogleMapPopover()

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

  # Adds one of our custom map controls to the map
  addControl: (control) ->
    control.setMap(@googleMap)
  
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
      shadow: null,
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
      @trigger 'mapListingFocussed', listing

    google.maps.event.addListener marker, 'mouseout', =>
      if listing.shouldBlur()
        @blurMarker(marker)
        @trigger 'mapListingBlurred', listing

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
  
  resizeToFillViewport: ->
    offset = $(@container).offset()
    viewport = $(window).height()
    $(@container).height(viewport - offset.top)
  
  # Return an array of [nx, ny, sx, sy] coordinates
  getBoundsArray: ->
    bounds = @googleMap.getBounds()
    ne = bounds.getNorthEast()
    sw = bounds.getSouthWest()
    [ne.lat(), ne.lng(), sw.lat(), sw.lng()]

  showInfoWindowForListing: (listing) ->
    marker = @markers[listing.id()]
    return unless marker

    @popover.setContent listing.popupContent()
    @popover.open(@googleMap, marker)

    # Focus the listing marker immediately for visual UX
    listing.popoverOpened()
    @focusListingMarker(listing)
    @trigger 'mapListingFocussed', listing

    # Blur the listing marker the next time the popover is closed
    @popover.one 'closed', =>
      listing.popoverClosed()
      @blurListingMarker(listing)
      @trigger 'mapListingBlurred', listing

  cacheMarkers: ->
    # hack if css sprites cannot be used
    $('body').append("<div style='display:none;'><img src='/assets/google-maps/marker-images/hover-2x.png' /><img src='/assets/google-maps/marker-images/default-2x.png' /></div>")
  
  show: ->
    $(@container).show()
    
  hide: ->
    $(@container).hide()
