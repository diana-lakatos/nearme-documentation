class Search.SearchMixedController extends Search.SearchController

  constructor: (form, @container) ->
    @resultsContainer = => @container.find('.locations')
    @hiddenResultsContainer = => @container.find('.hidden-locations')
    @list_container = => @container.find('div[data-list]')
    @sortField = @container.find('#sort')
    super(form, @container)
    @adjustListHeight()
    @sortValue = @sortField.find(':selected').val()
    @bindLocationsEvents()

  bindEvents: =>
    super
    $(window).resize =>
      @adjustListHeight()

    @sortField.on 'change', =>
      if @sortValue != @sortField.find(':selected').val()
        @sortValue = @sortField.find(':selected').val()
        @form.submit()

    @queryField.keypress (e) =>
      if e.which == 13
        # if user pressed enter, we will prevent submitting the form and do it manually, when we are ready [ i.e. after geocoding query ]
        @submit_form = false
        query = @queryField.val()
        deferred = @geocoder.geocodeAddress(query)
        deferred.always (results) =>
          result = results.getBestResult() if results
          @clearBoundParams()
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

    $(document).on 'click', '.pagination a', (e) =>
      e.preventDefault()
      link = $(e.target)
      page_regexp = /page=(\d+)/gm
      @loader.show()
      @triggerSearchFromQuery(page_regexp.exec(link.attr('href'))[1])


  initializeSearchButton: ->
    @searchButton = @form.find(".search-icon")
    if @searchButton.length > 0
      @searchButton.bind 'click', =>
        @clearBoundParams()
        @form.submit()


  adjustListHeight: ->
    @list_container().height($(window).height() - @list_container().offset().top)


  initializeMap: ->
    mapContainer = @container.find('#listings_map')[0]
    return unless mapContainer
    @map = new Search.MapMixed(mapContainer, this)

    # Add our map viewport search control, which enables/disables searching on map move
    @redoSearchMapControl = new Search.RedoSearchMapControl(enabled: true)
    @map.addControl(@redoSearchMapControl)

    resizeMapThrottle = _.throttle((=> @map.resizeToFillViewport()), 200)

    $(window).resize resizeMapThrottle
    $(window).trigger('resize')

    @updateMapWithListingResults()


  initializeAutocomplete: ->
    @autocomplete = new google.maps.places.Autocomplete(@queryField[0], {})
    google.maps.event.addListener @autocomplete, 'place_changed', =>
      if @submit_form
        @loader.show()
        @submit_form = false
        @form.submit()
      else
        place = Search.Geocoder.wrapResult @autocomplete.getPlace()
        place = null unless place.isValid()
        @setGeolocatedQuery(@queryField.val(), place)


  markerClicked: (marker) ->
    @processingResults = true
    listing = @map.getListingForMarker(marker)
    location_container = @resultsContainer().find("article[data-id=#{listing.id()}]")
    if location_container.length > 0
      animate_position = location_container.position().top + @list_container().offset().top + @list_container().find('.filters').height() - 55
      @list_container().animate
        scrollTop: animate_position
        () =>
          @unmarkAllLocations()
          location_container.addClass('active')
          @processingResults = false


  getListingsFromResults: ->
    listings = []
    @hiddenResultsContainer().find('.location-marker').each (i, el) =>
      listing = @listingForElementOrBuild(el)
      listings.push listing
    listings


  initializeEndlessScrolling: ->
    @list_container().scrollTop(0)


  unmarkAllLocations: ->
    @resultsContainer().find('article').removeClass('active')


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
  triggerSearchFromQuery: (page = false) ->
    # assign filter values
    @assignFormParams(
      lntype: _.toArray(@container.find('input[name="location_types_ids[]"]:checked').map(-> $(this).val())).join(',')
      lgtype: _.toArray(@container.find('input[name="listing_types_ids[]"]:checked').map(-> $(this).val())).join(',')
      lgpricing: _.toArray(@container.find('input[name="listing_pricing[]"]:checked').map(-> $(this).val())).join(',')
      sort: @container.find('#sort').val()
      loc: @form.find("input#search").val().replace(', United States', '')
      page: page || 1
    )
    super


  updateResultsCount: ->
    count = parseInt(@hiddenResultsContainer().find('input#result_count').val())
    inflection = 'location'
    inflection += 's' unless count == 1
    @resultsCountContainer.html("<span>#{count}</span> #{inflection}")
    @initializeEndlessScrolling()


  updateMapWithListingResults: ->
    @map.resetMapMarkers()

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
      else
        # no results found, try to set map center on searched city
        query = @queryField.val()
        deferred = @geocoder.geocodeAddress(query)
        deferred.always (results) =>
          if results
            result = results.getBestResult()
            @map.setCenter(new google.maps.LatLng(result.lat(), result.lng()))
            @map.setZoom(11)
            @map.show()
            # In case the map is hidden
            @map.resizeToFillViewport()


  # Within the current map display, plot the listings from the current results. Remove listings
  # that aren't within the current map bounds from the results.
  plotListingResultsWithinBounds: ->
    @map.resetMapMarkers()
    super


  showResults: (html) ->
    @resultsContainer().replaceWith(html)
    @updateResultsCount()
    @list_container().scrollTop(0)
    @bindLocationsEvents()


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


  bindLocationsEvents: ->
    self = @
    @resultsContainer().find('article.location').on 'mouseout', ->
      self.unmarkAllLocations()
      location_id = $(this).data('id')
      marker = self.map.markers[location_id]
      if marker
        marker.setIcon(SearchResultsGoogleMapMarker.getMarkerOptions().default.image)
        marker.setZIndex(google.maps.Marker.MAX_ZINDEX)

    @resultsContainer().find('article.location').on 'mouseover', ->
      self.unmarkAllLocations()
      $(this).addClass('active')
      location_id = $(this).data('id')
      marker = self.map.markers[location_id]
      if marker
        marker.setIcon(SearchResultsGoogleMapMarker.getMarkerOptions().hover.image)
        marker.setZIndex(google.maps.Marker.MAX_ZINDEX + 1)


  clearBoundParams: ->
    @assignFormParams(
      page: 1
      nx: ''
      ny: ''
      sx: ''
      sy: ''
      lat: ''
      lng: ''
    )


  # Triggers a search request with the current map bounds as the geo constraint
  triggerSearchWithBounds: ->
    bounds = @map.getBoundsArray()
    @assignFormParams(
      nx: @formatCoordinate(bounds[0]),
      ny: @formatCoordinate(bounds[1]),
      sx: @formatCoordinate(bounds[2]),
      sy: @formatCoordinate(bounds[3]),
      ignore_search_event: 1,
      page: 1
    )

    @triggerSearchAndHandleResults =>
      @plotListingResultsWithinBounds()
      @assignFormParams(
        ignore_search_event: 1
      )


  # Returns special search params based on a geolocation result (Search.Geolocator.Result), or no result.
  searchParamsFromGeolocationResult: (result) ->
    params = { country: null, state: null, city: null, suburb: null, street: null, postcode: null }

    if result
      params['country'] = result.country()
      params['state']   = result.state()
      params['city']    = result.city()
      params['suburb']  = result.suburb()
      params['street']  = result.street()
      params['postcode']  = result.postcode()
      loc_components = []
      if params['city']
        loc_components.push params['city']
      if params['country'] and params['country'] == 'United States' and result.stateShort()
        loc_components.push result.stateShort()
      else if params['state']
        loc_components.push params['state']
      if params['country'] and params['country'] != 'United States'
        loc_components.push params['country']

      params['loc'] = loc_components.join(', ')
    else
      params['loc'] = @form.find("input#search").val().replace(', United States', '')

    params
