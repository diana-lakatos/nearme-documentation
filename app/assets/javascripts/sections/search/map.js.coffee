# Encapsulates the map behaviour for the serach results
class Search.Map
  asEvented.call(Map.prototype)

  constructor: (@container) ->
    # Map of listing ids to markers
    @markers = {}

    # Set up the Google maps object
    @googleMap = new google.maps.Map(@container, {
      zoom: 8,
      minZoom: 8,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      mapTypeControl: false
    })

    # Info window pops over and contains details for each marker/listing
    @infoWindow = new google.maps.InfoWindow() 

    # Keeps track of items within the bounds for repositioning the map
    @initializeListingBounds()

    # This initializes the bounds and map position
    @clearPlottedListings()

    $(window).resize =>
      google.maps.event.trigger(@googleMap, 'resize') 
      @fitBounds()

    # Notify observers when the map is dragged
    google.maps.event.addListener @googleMap, 'dragend', =>
      @trigger 'viewportChanged'

    google.maps.event.addListener @googleMap, 'zoom_changed', =>
      @trigger 'viewportChanged'

  clearPlottedListings: ->
    for listingId, marker of @markers
      marker.setMap(null)
    # Easiest way to clear the hash is to initialize a new one
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

  plotListings: (listings, clearPreviousPlot = true) ->
    @clearPlottedListings() if clearPreviousPlot
    @plotListing(listing, i) for listing, i in listings

  # Only plot a listing if it fits within the map bounds.
  # Returns whether or not a listing was plotted. 
  plotListingIfInMapBounds: (listing, offset = 0) ->
    latLng = listing.latLng()
    if @googleMap.getBounds().contains(latLng)
      @plotListing(listing, offset)
      true
    else
      false

  plotListing: (listing, offset = 0) ->
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

    setTimeout(->
      marker.setAnimation(google.maps.Animation.DROP)
      marker.setVisible(true)
    ,0)

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