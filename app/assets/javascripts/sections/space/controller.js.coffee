class @Space.Controller

  constructor: (@container, @options = {}) ->
    @mapAndPhotosContainer = $('.location-photos')
    @photosContainer = $('.photos-container')
    @mapContainer    = $('.map')
    @googleMapElementWrapper = @mapContainer.find('.map-container')
    @panoramaContainer = $('#panorama')
    @photosTab = $('#photos')
    @detailsTab = $('#details')

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
    # For each listing on the page, initialize a controller for handling booking
    # selection.
    for listingData in @options.bookings.listings
      listingController = new Bookings.Controller(@container.find(".listings [data-listing-id=#{listingData.id}]"),
        listingData,
        showReviewBookingImmediately: @options.bookings.returnedFromSession
      )

  setupMap: ->
    return unless @mapContainer.length > 0

    location = @mapContainer.find('address')
    latlng = new google.maps.LatLng(
      location.attr("data-lat"), location.attr("data-lng")
    )

    if @photosContainer.length > 0
      mapTypeId = google.maps.MapTypeId.ROADMAP
    else
      mapTypeId = google.maps.MapTypeId.SATELLITE

    @map = { map: null, markers: [] }
    @map.initialCenter = latlng
    @map.map = SmartGoogleMap.createMap(@googleMapElementWrapper[0], {
      zoom: 13,
      zoomControlOptions: {
          style:google.maps.ZoomControlStyle.SMALL
      },
      mapTypeControl: false,
      panControl: false,
      streetViewControl: false,
      center: latlng,
      mapTypeId: mapTypeId
    })

    marker =  new google.maps.Marker({
      position: latlng,
      map: @map.map,
      icon: GoogleMapMarker.getMarkerOptions().default.image,
      shadow: null,
      shape: GoogleMapMarker.getMarkerOptions().default.shape
    })

    if @panoramaContainer.length > 0
      panoramaOptions = {
        position: latlng,
        addressControl: false,
        linksControl: false,
        panControl: false,
        zoomControlOptions: {
          style: google.maps.ZoomControlStyle.SMALL
        },
        enableCloseButton: false,
        visible:true
      }
      @panorama = new google.maps.StreetViewPanorama(document.getElementById(@panoramaContainer.attr('id')), panoramaOptions)
      @map.map.setStreetView(@panorama)


    @map.markers.push marker

    @popover = new GoogleMapPopover({'boxStyle': { 'width': '190px' }, 'pixelOffset': new google.maps.Size(-95, -40) })
    @popover.setContent @mapContainer.find('address').html()
    @popover.open(@map.map, marker)

    google.maps.event.addListener marker, 'click', =>
      @popover.open(@map.map, marker)

    @setupMapHeightConstraintToPhotosSection()
    @listenToTabs()

  # TODO: There's potentially a better way to do this, by constraining the dimensions via a
  #       defined aspect ratio for the the map and the photos and using a dom wrapper to maintain that
  #       aspect ratio (%'age padding with abs. positioned inner container).
  #       At some point we can look into that but this works for now.
  setupMapHeightConstraintToPhotosSection: ->

    @constrainer = null
    if @photosContainer.find('.item').length > 0
      return unless @map
      # We use a known aspect ratio to determine the dynamic height because:
      #   a) If the image hasn't loaded yet we won't have the height
      #   b) Likewise if the image won't load (error, etc.) we wouldn't otherwise get a relevant height
      aspectRatioW = parseInt(@mapAndPhotosContainer.attr('data-photo-aspect-w'))
      aspectRatioH = parseInt(@mapAndPhotosContainer.attr('data-photo-aspect-h'))


      @constrainer = new HeightConstrainer(
        @googleMapElementWrapper,
        @photosContainer,
        ratio: aspectRatioH/aspectRatioW
      )

    # when we resize browser, height of google map is being adjusted based on photo's width. However, when we are in #details tab, we need to disable those calculations,
    # because height is calculated wrongly for hidden elements. We need to reproduce the behaviour of the height adjustment also for #details tab, and this is what this code does
      details_constrainer = new HeightConstrainer(
        @detailsTab,
        @detailsTab,
    # 0.65755 was set based on trials and errors approach. Since photo is about 70% of full width, the remaining 30% is google map, I tried to make the same proportions
        ratio: (aspectRatioH/aspectRatioW)*0.65755
      )
    
    else
        @panoramaContainer.height(@googleMapElementWrapper.height())
        google.maps.event.trigger(@panorama, 'resize')
        google.maps.event.trigger(@panorama, 'zoom_changed')

  listenToTabs: ->
    if @constrainer
    # we do not want to listen to this event when there is no constrainer - height will not be updated via CSS @media, because of hardcoded style='height: XX' 
      $("a[href=##{@detailsTab.attr('id')}]").on 'show', =>
        @adjustDetailsHeightToPhotosHeight()

    # we want this to be listen always to avoid issue with rendering google map after toggling from invisible to visible
    $("a[href=##{@photosTab.attr('id')}]").on 'shown', =>
      if @constrainer
        # we need to not only resize map, but also update height of it - which is constrainer job
        @constrainer.constrain()
      google.maps.event.trigger(@map.map, 'resize')
      google.maps.event.trigger(@map.map, 'zoom_changed')
      @map.map.setCenter(@map.initialCenter)

  adjustDetailsHeightToPhotosHeight: ->
    # it would be great to use outerHeight, but it won't work ;-) need to be adjusted if detail
    #
    padding_top = parseInt(@detailsTab.css('padding-top'))
    padding_bottom = parseInt(@detailsTab.css('padding-bottom'))
    base_height = @photosTab.height() - parseInt(@photosTab.css('padding-bottom')) - parseInt(@photosTab.css('padding-top'))
    @detailsTab.height(base_height-padding_top-padding_bottom)

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


