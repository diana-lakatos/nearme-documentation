class @SpaceController

  constructor: (@container) ->
    # Set up the map on the page
    @setupMap()
    @setupPhotos()
    @setupBookings()

  setupPhotos: ->
    @photos = new SpacePhotosController($('.space-hero-photos'))

  setupBookings: ->
    @bookings = new SpaceController.SpaceBookingManager(@container.find('.bookings'))

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

  class @SpaceBookingManager
    constructor: (@container) ->
      @listings = $.map @container.find('.listings .listing'), (el) =>
        new Listing($(el))

      @setupCalendar()

    setupCalendar: ->
      @calendar = new SpaceBookingCalendar(@container.find('.calendar'))

      # Bind to date selection events
      @calendar.onSelect (date) =>
        listing.addDate(date) for listing in @listings

      @calendar.onUnselect (date) =>
        listing.removeDate(date) for listing in @listings


    # Each Listing has it's own object which keeps track of number booked, availability etc.
    class Listing
      constructor: (@container) ->
        @daysContainer = @container.find('.book .booked-days')

      addDate: (date) ->
        dateEl = @_prepareBookedDayElement(date)

        after = null
        @daysContainer.find('.booked-day').each (i, el) =>
          if $(el).data('date').getTime() < date.getTime()
            after = el

        if after
          $(after).after(dateEl)
        else
          @daysContainer.prepend(dateEl)

      removeDate: (date) ->
        console.info date
        @daysContainer.find(".#{DNM.util.Date.toClassName(date)}").remove()

      _prepareBookedDayElement: (date) ->
        el = $('<span class="booked-day empty"/>')
        el.append('<span class="count">0</span>')
        el.append("<span class=\"date\">#{date.getDate()}<sup>#{DNM.util.Date.suffix(date)}</sup></span>")
        el.append("<span class=\"month\">#{DNM.util.Date.monthName(date, 3)}</span>")
        el.addClass(DNM.util.Date.toClassName(date))
        el.data('date', date)
        el


