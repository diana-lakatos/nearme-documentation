# Controller for handling each reservation in my bookings page
#
# The controller is initialized with the reservation DOM container. It's mainly for controlling google map
# which has to be provided for each user's reservation
class @Reservation.UserReservationController

  constructor: (@container, @options = {}) ->
    @mapContainer = @container.find('.map').eq(0)
    @setMapDimensions()
    @googleMapElementWrapper = @mapContainer.find('.map-container')
    @setupMap()
    @bindEvents()

  bindEvents: ->
    $(window).resize =>
      @setMapDimensions()
      google.maps.event.trigger(@map.map, 'resize')

  setupMap: ->
    return unless @mapContainer.length > 0
    location = @mapContainer.find('address')
    @latlng = new google.maps.LatLng(location.attr("data-lat"), location.attr("data-lng"))
    mapTypeId = google.maps.MapTypeId.ROADMAP

    @map = { map: null, markers: [] }
    @map.initialCenter = @latlng
    @map.map = SmartGoogleMap.createMap(@googleMapElementWrapper[0], {
      zoom: 13,
      zoomControlOptions: {
          style:google.maps.ZoomControlStyle.SMALL
      },
      mapTypeControl: false,
      panControl: false,
      streetViewControl: false,
      center: @latlng,
      mapTypeId: mapTypeId
    })

    marker =  new google.maps.Marker({
      position: @latlng,
      map: @map.map,
      icon: GoogleMapMarker.getMarkerOptions().default.image,
      shadow: null,
      shape: GoogleMapMarker.getMarkerOptions().default.shape
    })
    @map.markers.push marker

    @popover = new GoogleMapPopover({'boxStyle': { 'width': '190px' }, 'pixelOffset': new google.maps.Size(-95, -40) })
    @popover.setContent @mapContainer.find('address').html()
    @popover.open(@map.map, marker)

    google.maps.event.addListener marker, 'click', =>
      @popover.open(@map.map, marker)

  setMapDimensions: ->
    @mapContainer.width(@mapContainer.parent().width())
    @mapContainer.height(@container.find('.reservation-text-information').height())
    if @map
      @map.map.setCenter(@latlng)
