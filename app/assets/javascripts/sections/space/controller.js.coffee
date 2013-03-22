class @Space.Controller

  constructor: (@container, @options = {}) ->
    @mapAndPhotosContainer = $('.location-photos')
    @photosContainer = $('.photos-container')
    @mapContainer    = $('.map')
    @googleMapElementWrapper = @mapContainer.find('.map-container')

    @setupCollapse()
    @setupCarousel()
    @setupMap()
    @setupPhotos()
    @setupBookings()
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
    @bookings = new Bookings.Controller(@container.find('.bookings'), @options.bookings)

  setupMap: ->
    return unless @mapContainer.length > 0

    location = @mapContainer.find('address')
    latlng = new google.maps.LatLng(
      location.attr("data-lat"), location.attr("data-lng")
    )

    @map = { map: null, markers: [] }
    @map.initialCenter = latlng
    @map.map = new google.maps.Map(@googleMapElementWrapper[0], {
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

    @setupMapHeightConstraintToPhotosSection()

  # TODO: There's potentially a better way to do this, by constraining the dimensions via a
  #       defined aspect ratio for the the map and the photos and using a dom wrapper to maintain that
  #       aspect ratio (%'age padding with abs. positioned inner container).
  #       At some point we can look into that but this works for now.
  setupMapHeightConstraintToPhotosSection: ->
    return unless @photosContainer.length > 0
    return unless @map
    # We use a known aspect ratio to determine the dynamic height because:
    #   a) If the image hasn't loaded yet we won't have the height
    #   b) Likewise if the image won't load (error, etc.) we wouldn't otherwise get a relevant height
    aspectRatioW = parseInt(@mapAndPhotosContainer.attr('data-photo-aspect-w'))
    aspectRatioH = parseInt(@mapAndPhotosContainer.attr('data-photo-aspect-h'))

    constrainer = new HeightConstrainer(
      @googleMapElementWrapper,
      @photosContainer,
      ratio: aspectRatioH/aspectRatioW
    )
    constrainer.on 'constrained', =>
      google.maps.event.trigger(@map.map, 'resize')
      @map.map.setCenter(@map.initialCenter)

  setupCarousel: ->
    carouselContainer = $(".carousel")
    return unless carouselContainer.length > 0
    carouselContainer.carousel({
      pills: false,
      interval: 10000
    })

  setupCollapse: ->
    collapseContainer = $(".accordion")
    return unless collapseContainer.length > 0
    collapseContainer.on('show hide', -> $(this).css('height', 'auto') )
    collapseContainer.collapse({ parent: true, toggle: true })


