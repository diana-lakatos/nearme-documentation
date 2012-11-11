class @Space.Controller

  constructor: (@container) ->
    # Set up the map on the page
    @setupMap()
    @setupPhotos()
    @setupBookings()

  setupPhotos: ->
    @photos = new Space.PhotosController($('.space-hero-photos'))

  setupBookings: ->
    @bookings = new Space.BookingManager(@container.find('.bookings'))

  setupMap: ->
    mapContainer = @container.find('.map')
    location = mapContainer.find('address')
    latlng = new google.maps.LatLng(
      location.attr("data-lat"), location.attr("data-lng")
    )

    @map = { map: null, markers: [] }
    @map.map = new google.maps.Map(mapContainer.find('.map-container')[0], {
      zoom: 13,
      mapTypeControl: false,
      streetViewControl: false,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })

    @map.markers.push new google.maps.Marker({
      position: latlng,
      map: @map.map,
      icon: location.attr("data-marker")
    })


