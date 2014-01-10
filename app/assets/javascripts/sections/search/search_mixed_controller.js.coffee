class Search.SearchMixedController extends Search.SearchController

  constructor: (form, @container) ->
    @resultsContainer = => @container.find('.locations')
    @hiddenResultsContainer = => @container.find('.hidden-locations')
    @list_container = => @container.find('div[data-list]')
    @sortField = @container.find('#sort')
    super(form, @container)
    @adjustListHeight()
    @sortValue = @sortField.find(':selected').val()

  bindEvents: =>
    super
    $(window).resize =>
      @adjustListHeight()

    @sortField.on 'change', =>
      if @sortValue != @sortField.find(':selected').val()
        @sortValue = @sortField.find(':selected').val()
        @fieldChanged()

    @queryField.keypress (e) =>
      if e.which == 13
        # if user pressed enter, we will prevent submitting the form and do it manually, when we are ready [ i.e. after geocoding query ]
        @submit_form = false
        query = @queryField.val()
        deferred = @geocoder.geocodeAddress(query)
        deferred.always (results) =>
          result = results.getBestResult() if results
          @setGeolocatedQuery(query, result)
          @submit_form = true
          _.defer =>
            google.maps.event.trigger(@autocomplete, 'place_changed')
        false
      else
        @submit_form = false
        true

    @searchButton.bind 'click', =>
      @submit_form = true

  adjustListHeight: ->
    @list_container().height($(window).height() - @list_container().offset().top)


  initializeMap: ->
    super
    @map.clusterer.addListener 'click', (cluster) =>
      @processingResults = true
      listings = _.map(cluster.getMarkers(), (marker) => @map.getListingForMarker(marker))
      listings_query = '.listing[data-id="' + listings[listings.length - 1]._id + '"]'
      location_container = @resultsContainer().find("div#{listings_query}").parents('.location')
      if location_container.length > 0
        animate_position = location_container.position().top + @list_container().offset().top
        @list_container().animate
          scrollTop: animate_position
          () =>
            @processingResults = false
      else
        location_id = @hiddenResultsContainer().find("article#{listings_query}").data('location')
        @getPageWithLocation(location_id)

    google.maps.event.addListener @map.googleMap, 'zoom_changed', =>
      @map.clusterer.setZoomOnClick(false)

  initializeAutocomplete: ->
    @autocomplete = new google.maps.places.Autocomplete(@queryField[0], {})
    google.maps.event.addListener @autocomplete, 'place_changed', =>
      if @submit_form
        @submit_form = false
        @fieldChanged('query', @queryField.val())
      else
        place = Search.Geocoder.wrapResult @autocomplete.getPlace()
        place = null unless place.isValid()
        @setGeolocatedQuery(@queryField.val(), place)


  getPageWithLocation: (location_id) ->
    @assignFormParams(
      page_with_location: location_id
    )
    @loader.showWithoutLocker()
    @triggerSearchRequest().success (html) =>
      $.waypoints('destroy')
      @processingResults = true
      @showResults(html)
      @loader.hide()
      location_container = @resultsContainer().find('article.location[data-id="' + location_id + '"]')
      if location_container.length > 0
        @assignFormParams(
          page_with_location: ''
        )
        @lastListPosition = null
        @setListOnLocation(location_id)
      @processingResults = false


  setListOnLocation: (location_id) ->
    setTimeout( =>
      _.defer =>
        @list_container().get(0).scrollTop = $('article.location[data-id=' + location_id + ']').position().top + @list_container().offset().top
        if @list_container().get(0).scrollTop != @lastListPosition
          @lastListPosition = @list_container().get(0).scrollTop
          @setListOnLocation(location_id)
        @initializeWaypoints()
    , 1500)


  getListingsFromResults: ->
    listings = []
    @hiddenResultsContainer().find('article.listing').each (i, el) =>
      listing = @listingForElementOrBuild(el)
      listings.push listing
    listings

  initializeWaypoints: ->
    $.waypoints('destroy')
    top_pagination = $('.top-pagination .pagination')
    bottom_pagination = $('.bottom-pagination .pagination')
    top_pagination.hide()
    bottom_pagination.hide()
    loader = $('<div class="ias_loader"><h1><img src="' + $('img[alt=Spinner]').eq(0).attr('src') + '"><span>Loading More Results</span></h1></div>')
    next_url = bottom_pagination.find('.next_page').attr('href')
    if next_url
      $('article.location').last().waypoint
        handler: =>
          bottom_pagination.before(loader)
          $.get next_url,
            (results) =>
              loader.remove()
              bottom_pagination.before($(results).find('article.location'))
              bottom_pagination.replaceWith($(results).find('.bottom-pagination .pagination'))
              @initializeWaypoints()
        context: 'div[data-list]'
        offset: $(window).height() - $('article.location').last().height()
        triggerOnce: true
        continuous: false

    previous_url = top_pagination.find('.previous_page').attr('href')
    first_location = $('article.location').first()
    if previous_url and parseInt(first_location.data('offset')) != 0
      first_location.waypoint
        handler: =>
          top_pagination.after(loader)
          $.get previous_url,
            (results) =>
              loader.remove()
              top_pagination.after($(results).find('article.location'))
              top_pagination.replaceWith($(results).find('.top-pagination .pagination'))
              setTimeout( =>
                @list_container().get(0).scrollTop = $('article.location[data-id=' + first_location.data('id') + ']').position().top + @list_container().offset().top
                @initializeWaypoints()
              , 200)
        context: 'div[data-list]'
        offset: 100
        triggerOnce: true
        continuous: false
        onlyOnScroll: true

  initializeEndlessScrolling: ->
    @list_container().scrollTop(0)
    @initializeWaypoints()


  # Trigger the API request for search
  #
  # Returns a jQuery Promise object which can be bound to execute response semantics.
  triggerSearchRequest: ->
    @currentAjaxRequest.abort() if @currentAjaxRequest
    @currentAjaxRequest = $.ajax(
      url  : @form.attr("action")
      type : 'GET',
      data : @form.add('.list .sort :input').serialize()
    )


  # Trigger the search from manipulating the query.
  # Note that the behaviour semantics are different to manually moving the map.
  triggerSearchFromQuery: ->
    # assign filter values
    @assignFormParams(
      lntype: _.toArray(@container.find('input[name="location_types_ids[]"]:checked').map(-> $(this).val())).join(',')
      lgtype: _.toArray(@container.find('input[name="listing_types_ids[]"]:checked').map(-> $(this).val())).join(',')
      lgpricing: _.toArray(@container.find('input[name="listing_pricing[]"]:checked').map(-> $(this).val())).join(',')
      sort: @container.find('#sort').val()
      loc: @form.find("input#search").val().replace(', United States', '')
    )
    super


  updateResultsCount: ->
    count = parseInt(@hiddenResultsContainer().find('input#result_count').val())
    inflection = 'location'
    inflection += 's' unless count == 1
    @resultsCountContainer.html("<span>#{count}</span> #{inflection}")
    @initializeEndlessScrolling()


  updateMapWithListingResults: ->
    @map.markers = {}
    @map.clusterer.clearMarkers()
    @map.popover.close()

    listings = @getListingsFromResults()

    if listings? and listings.length > 0
      @map.plotListings(listings)

      # Only show bounds of new results
      bounds = new google.maps.LatLngBounds()
      bounds.extend(listing.latLng()) for listing in listings
      _.defer => @map.fitBounds(bounds)
      @map.show()
      # In case the map is hidden
      @map.resizeToFillViewport()
    else
      if @form.find('input[name=lat]').val() != ''
        map_center = new google.maps.LatLng(@form.find('input[name=lat]').val(), @form.find('input[name=lng]').val())
        _.defer => @map.setCenter(map_center)
        @map.show()
        # In case the map is hidden
        @map.resizeToFillViewport()

    setTimeout( =>
      @map.clusterer.redraw_()
    , 500)


  # Within the current map display, plot the listings from the current results. Remove listings
  # that aren't within the current map bounds from the results.
  plotListingResultsWithinBounds: ->
    @map.markers = {}
    @map.clusterer.clearMarkers()
    super
    @map.clusterer.redraw_()


  showResults: (html) ->
    super(html)
    @updateResultsCount()
    @list_container().scrollTop(0)


  # Trigger automatic updating of search results
  fieldChanged: (field, value) ->
    @triggerSearchFromQueryAfterDelay()


  updateUrlForSearchQuery: ->
    url = document.location.href.replace(/\?.*$/, "")
    params = @getSearchParams()
    filtered_params = []
    for k, param of params
      if $.inArray(param["name"], ['lgtype', 'lntype', 'loc', 'lgpricing']) > -1
        filtered_params.push {name: param["name"], value: param["value"]}

    # we need to decodeURIComponent, otherwise accents will not be handled correctly. Remove decodeURICompoent if we switch back
    # to window.history.replaceState, but it's *absolutely mandatory* in this case. Removing it now will lead to infiite redirection in IE lte 9
    url = decodeURIComponent("?#{$.param(filtered_params)}")
    History.replaceState(params, @container.find('input[name=meta_title]').val(), url)
