# Encapsulates the map behaviour for the serach results
class Search.Map
  asEvented.call(Map.prototype)

  constructor: (@container) ->
    @initializeGoogleMap()
    @bindEvents()

  initializeGoogleMap: ->
    @googleMap = new google.maps.Map(@container, {
      zoom: 8,
      minZoom: 4,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      disableDefaultUI: true
      zoomControl: true
    })

    # Info window pops over and contains details for each marker/listing
    @infoWindow = new google.maps.InfoWindow() 
    @resetMapMarkers()

  bindEvents: ->
    # Ensure the map is notified of window resize, and positioning adjusted.
    $(window).resize =>
      google.maps.event.trigger(@googleMap, 'resize') 
      @fitBounds()

    google.maps.event.addListener @googleMap, 'dragend', =>
      @trigger 'viewportChanged'

    google.maps.event.addListener @googleMap, 'zoom_changed', =>
      @trigger 'viewportChanged'

  # Clears any plotted listings and resets the map
  resetMapMarkers: ->
    marker.setMap(null) for listingId, marker of @markers if @markers
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
      visible:  false
    )
    @markers[listing.id()] = marker
    @bounds.extend(listing.latLng())

    marker.setAnimation(google.maps.Animation.DROP)
    marker.setVisible(true)

    # Bind the event for showing the info details on click
    google.maps.event.addListener marker, 'click', =>
      @showInfoWindowForListing(listing)

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
