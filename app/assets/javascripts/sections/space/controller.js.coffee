class @Space.Controller

  constructor: (@container, @options = {}) ->
    # Set up the map on the page
    @setupMap()
    @setupPhotos()
    @setupBookings()
    @setupQuickBook()
    @_bindEvents()

  _bindEvents: ->
    @container.on 'click', '[data-behavior=scrollToBook]', (event) =>
      event.preventDefault()
      $('html, body').animate({
        scrollTop: $(".bookings").offset().top - 20
      }, 300)

  setupPhotos: ->
    @photos = new Space.PhotosController($('.space-hero-photos'))

  setupBookings: ->
    @bookings = new Space.BookingManager(@container.find('.bookings'), @options.bookings)

  setupMap: ->
    mapContainer = $(".map")
    return unless mapContainer.length > 0

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

  setupQuickBook: ->
    @quickbook = new Space.QuickBook(@container.find('.quick-book'))

