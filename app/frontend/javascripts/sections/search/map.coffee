asEvented = require('asevented')
MarkerClusterer = require('../../../vendor/markerclusterer')
SmartGoogleMap = require('../../components/smart_google_map')
GoogleMapPopover = require('../../components/google_map_popover')

# Encapsulates the map behaviour for the serach results
module.exports = class SearchMap
  asEvented.call @prototype

  GOOGLE_MAP_OPTIONS =
    zoom: 12,
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
    @loading = false
    @current_position = { getPosition: -> {} }
    @search_controller = controller

  initializeGoogleMap: ->
    @googleMap = SmartGoogleMap.createMap(@container, GOOGLE_MAP_OPTIONS, { exclude: ['draggable'] })
    @clusterer = new MarkerClusterer(@googleMap, [], GOOGLE_MAP_OPTIONS.clusterer)

    # Info window pops over and contains details for each marker/listing
    @popover = new GoogleMapPopover()

    # need to toggle scroll wheel because of overflow: auto
    # need to remember which cluster has been open to prevent re-opening the same one
    @popover.on 'closed', =>
      @googleMap.setOptions({scrollwheel: true})
      $(@container).removeClass('popover-opened')
      @current_position = {}
    @popover.on 'opened', =>
      $(@container).addClass('popover-opened')
      @googleMap.setOptions({scrollwheel: false})
      @current_position = @current_cluster_position

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

    google.maps.event.addListener @googleMap, 'click', (e) =>
      @popover.close()
      @trigger 'click'

    @clusterer.addListener 'mouseover', (cluster) =>
      _.defer => @showInfoWindowForCluster(cluster) # Clashes with map.click on some devices, need to add small delay to show

    @clusterer.addListener 'click', (cluster) =>
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
      shadow: null,
      shape: GoogleMapMarker.getMarkerOptions().default.shape
    )
    @markers[listing.id()] = marker
    @listings[listing.id()] = listing
    @bounds.extend(listing.latLng())
    @clusterer.addMarker(marker)

    marker.setVisible(true)

  fitBounds: (bounds) ->
    @googleMap.fitBounds(bounds || @bounds)

  setCenter: (latLng) ->
    @googleMap.setCenter(latLng)

  resizeToFillViewport: ->
    offset = $(@container).offset()
    viewport = $(window).height()
    $(@container).height(viewport - offset.top)
    _.defer => google.maps.event.trigger(@googleMap, 'resize')
    true

  # Return an array of [nx, ny, sx, sy] coordinates
  getBoundsArray: ->
    bounds = @googleMap.getBounds()
    if bounds
      ne = bounds.getNorthEast()
      sw = bounds.getSouthWest()
      [ne.lat(), ne.lng(), sw.lat(), sw.lng()]
    else
      [0, 0, 0, 0]

  getListingForMarker: (marker) ->
    listing_id = null
    for idx, _marker of @markers
      if _marker is marker
        listing_id = idx
        break
    return @listings[listing_id]

  showInfoWindowForCluster: (cluster) ->

    if !@loading && @current_position != cluster.center_
      @current_cluster_position = cluster.center_
      if cluster.getMarkers().length > 100
        @popover.setError('Maximum listings per marker is 100. Click the marker to zoom in.')
      else
        @loading = true
        @popover.markAsBeingLoaded()
        listings = _.map(cluster.getMarkers(), (marker) => @getListingForMarker(marker))
        listingsByLocation = _.groupBy(_.compact(listings), (listing) -> listing.location())
        _.defer =>
          @search_controller.updateListings(listings, =>
            html = ""
            for location, group of listingsByLocation
              html += group[0].popoverTitleContent()
              html += listing.popoverContent() for listing in group

            @popover.setContent html
            @loading = false
          , =>
            @popover.setError "An error occured retrieving listings, please try again."
            @loading = false
          )
      @popover.open @googleMap, { getPosition: -> cluster.center_ }

    true

  showInfoWindowForListing: (listing) ->
    marker = @markers[listing.id()]
    return unless marker
    @search_controller.updateListing(listing,  =>
      @popover.setContent listing.popoverTitleContent() + listing.popoverContent()
      @popover.open(@googleMap, marker))

  show: ->
    $(@container).show()

  hide: ->
    $(@container).hide()
