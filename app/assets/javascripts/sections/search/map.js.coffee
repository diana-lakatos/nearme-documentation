# Encapsulates the map behaviour for the serach results
class Search.Map
  asEvented.call(Map.prototype)

  # Custom marker definitions
  # Generated from: http://powerhut.co.uk/googlemaps/custom_markers.php
  MARKERS =
    hover:
      icon:
        url: '/assets/google-maps/marker-images/hover-2x.png'
        size: new google.maps.Size(20,29)
        origin: new google.maps.Point(0,0)
        anchor: new google.maps.Point(10,29)
        scaledSize: new google.maps.Size(20,29)
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
      icon:
        url: '/assets/google-maps/marker-images/default-2x.png'
        size: new google.maps.Size(40,57)
        origin: new google.maps.Point(0,0)
        anchor: new google.maps.Point(10,29)
        scaledSize: new google.maps.Size(20,29)
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
  
  GOOGLE_MAP_OPTIONS =
    zoom: 8,
    minZoom: 4,
    maxZoom: 18,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    disableDefaultUI: true,
    zoomControl: true
    
  GOOGLE_MAP_OPTIONS.clusterer =
    maxZoom: GOOGLE_MAP_OPTIONS.maxZoom + 1
    averageCenter: true
    minimumClusterSize: 1
    styles:
      [
        { width: 22, height: 22, url: 'assets/images/transparent.png' },
        { width: 26, height: 26, url: 'assets/images/transparent.png' },
        { width: 36, height: 36, url: 'assets/images/transparent.png' }
      ]
    calculator: (markers, numStyles) ->
      idx = MarkerClusterer.CALCULATOR(markers, numStyles).index
      return { index: idx, text: markers.length.toString(), title: markers.length.toString() }
  
  constructor: (@container, controller) ->
    @initializeGoogleMap()
    @bindEvents()
    @cacheMarkers()
    @search_controller = controller

  initializeGoogleMap: ->
    @googleMap = SmartGoogleMap.createMap(@container, GOOGLE_MAP_OPTIONS, { exclude: ['draggable'] })
    @clusterer = new MarkerClusterer(@googleMap, [], GOOGLE_MAP_OPTIONS.clusterer)

    # Info window pops over and contains details for each marker/listing
    @popover = new GoogleMapPopover()

    # need to toggle scroll wheel because of overflow: auto
    @popover.on 'closed', =>
      @googleMap.setOptions({scrollwheel: true})
    @popover.on 'opened', =>
      @googleMap.setOptions({scrollwheel: false})

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
      @clusterer.setZoomOnClick(@googleMap.getZoom() < GOOGLE_MAP_OPTIONS.maxZoom)
      @popover.close()
    
    google.maps.event.addListener @googleMap, 'click', (e)=>
      @popover.close()
      @trigger 'click'
    
    @clusterer.addListener 'mouseover', (cluster)=>
      return if cluster.markers_.length > 1 && @googleMap.getZoom() != GOOGLE_MAP_OPTIONS.maxZoom
      _.defer => @showInfoWindowForCluster(cluster) # Clashes with map.click on some devices, need to add small delay to show

    @clusterer.addListener 'click', (cluster)=>
      return if @googleMap.getZoom() < GOOGLE_MAP_OPTIONS.maxZoom
      _.defer => @showInfoWindowForCluster(cluster) # Clashes with map.click on some devices, need to add small delay to show
      
    null
  
  # Adds one of our custom map controls to the map
  addControl: (control) ->
    control.setMap(@googleMap)
  
  # Clears any plotted listings and resets the map
  resetMapMarkers: ->
    if @markers
      for listingId, marker of @markers
        marker.setMap(null)

    @markers = {}
    @listings = {}
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
      icon: MARKERS.default.icon,
      shadow: null,
      shape: GoogleMapMarker.getMarkerOptions().default.shape
    )
    @markers[listing.id()] = marker
    @listings[listing.id()] = listing
    @bounds.extend(listing.latLng())
    @clusterer.addMarker(marker)
    
    marker.setVisible(true)

    # Bind the event for showing the info details on click
    google.maps.event.addListener marker, 'mouseover', =>
      @showInfoWindowForListing(listing)

  fitBounds: (bounds) ->
    @googleMap.fitBounds(bounds || @bounds)
  
  resizeToFillViewport: ->
    offset = $(@container).offset()
    viewport = $(window).height()
    $(@container).height(viewport - offset.top)
    _.defer => google.maps.event.trigger(@googleMap, 'resize')
    true
  
  # Return an array of [nx, ny, sx, sy] coordinates
  getBoundsArray: ->
    bounds = @googleMap.getBounds()
    ne = bounds.getNorthEast()
    sw = bounds.getSouthWest()
    [ne.lat(), ne.lng(), sw.lat(), sw.lng()]
    
  getListingForMarker: (marker) ->
    listing_id = null
    for idx, _marker of @markers
      if _marker is marker
        listing_id = idx
        break
    return @listings[listing_id]

  showInfoWindowForCluster: (cluster) ->
    
    listings = _.map(cluster.getMarkers(), (marker) => @getListingForMarker(marker))
    listingsByLocation = _.groupBy(_.compact(listings), (listing) -> listing.location())

    @search_controller.updateListings(listings, =>
      html = ""
      for location, group of listingsByLocation
        html += group[0].popoverTitleContent()
        html += listing.popoverContent() for listing in group
        
      @popover.setContent html
      @popover.open @googleMap, cluster.getMarkers()[0])
    
    true

  showInfoWindowForListing: (listing) ->
    marker = @markers[listing.id()]
    return unless marker
    @search_controller.updateListing(listing,  =>
      @popover.setContent listing.popoverTitleContent() + listing.popoverContent()
      @popover.open(@googleMap, marker))

  cacheMarkers: ->
    # hack if css sprites cannot be used
    $('body').append("<div style='display:none;'><img src='/assets/google-maps/marker-images/hover-2x.png' /><img src='/assets/google-maps/marker-images/default-2x.png' /></div>")
  
  show: ->
    $(@container).show()
    
  hide: ->
    $(@container).hide()
