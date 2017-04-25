require('history.js/history')
require('history.js/history.adapter.ender')
SearchSearchController = require('./search_controller')
urlUtil = require('../../lib/utils/url')
SearchMapMixed = require('./map_mixed')
SearchRedoSearchMapControl = require('./redo_search_map_control')
SearchResultsGoogleMapMarker = require('../../components/search_results_google_map_marker')
CustomInputs = require('../../components/custom_inputs')
SearchGeocoder = require('./geocoder')


module.exports = class SearchMixedController extends SearchSearchController

  constructor: (form, @container) ->
    @resultsContainer = => @container.find('.locations')
    @hiddenResultsContainer = => @container.find('.hidden-locations')
    @list_container = => @container.find('div[data-list]')
    @sortField = @container.find('#sort')
    @perPageField = @container.find('#per_page')
    super(form, @container)
    @adjustListHeight()
    @sortValue = @sortField.find(':selected').val()
    @perPageValue = @perPageField.find(':selected').val()
    @bindLocationsEvents()
    @initializeCarousel()
    @initializePriceSlider()
    params_category_ids = urlUtil.getParameterByName('category_ids').split(',')
    @renderChildCategories(params_category_ids)
    @autocompleteCategories()
    @setListingCounter()


  bindEvents: =>
    super
    $(window).resize =>
      @adjustListHeight()

    @sortField.on 'change', =>
      if @sortValue != @sortField.find(':selected').val()
        @sortValue = @sortField.find(':selected').val()
        @form.submit()

    @perPageField.on 'change', =>
      if @perPageValue != @perPageField.find(':selected').val()
        @perPageValue = @perPageField.find(':selected').val()
        @form.submit()

    if @autocompleteEnabled()
      $('input.query').keypress (e) =>
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
      link = $(e.target).closest('a')
      @loader.show()
      res = /page=(\d+)/gm.exec(link.attr('href'))
      @triggerSearchFromQuery(res[1]) if res[1]

    $(document).on 'click', '.list .locations .location .listing', (e) ->
      unless $(e.target).hasClass('truncated-ellipsis')
        if $(e.target).hasClass('listing')
          window.location.href = $(e.target).find('.reserve-listing a').attr('href')
        else
          window.location.href = $(e.target).parents('.listing').find('.reserve-listing a').attr('href')

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
    @map = new SearchMapMixed(mapContainer, this)


    # Add our map viewport search control, which enables/disables searching on map move
    @redoSearchMapControl = new SearchRedoSearchMapControl(enabled: true, update_text: $(mapContainer).data('update-text'))
    resizeMapThrottle = _.throttle((=> @map.resizeToFillViewport()), 200)

    $(window).resize resizeMapThrottle
    $(window).trigger('resize')

    @updateMapWithListingResults()
    @map.addControl(@redoSearchMapControl)


  initializeAutocomplete: ->
    options = {}
    restrictCountries = @queryField.data('restrict-countries')
    if restrictCountries && restrictCountries.length > 0
      options['componentRestrictions'] = { 'country': restrictCountries }

    @autocomplete = new google.maps.places.Autocomplete(@queryField[0], options)
    google.maps.event.addListener @autocomplete, 'place_changed', =>
      if @submit_form
        @loader.show()
        @submit_form = false
        @form.submit()
      else
        place = SearchGeocoder.wrapResult @autocomplete.getPlace()
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
        =>
          @unmarkAllLocations()
          location_container.addClass('active')
          @processingResults = false


  getListingsFromResults: ->
    listings = []
    @resultsContainer().find('.location-marker').each (i, el) =>
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
    data = @form.add('.list .sort :input').serializeArray()
    data.push({"name": "map_moved", "value": @mapTrigger})
    @currentAjaxRequest = $.ajax(
      url  : @form.attr("action")
      type : 'GET',
      data : $.param(data)
    )


  # Trigger the search from manipulating the query.
  # Note that the behaviour semantics are different to manually moving the map.
  triggerSearchFromQuery: (page = false) ->
    # assign filter values
    @assignFormParams(
      lntype: _.toArray(@container.find('input[name="location_types_ids[]"]:checked').map(-> $(this).val())).join(',')
      lgpricing: _.toArray(@container.find('input[name="listing_pricing[]"]:checked').map(-> $(this).val())).join(',')
      sort: @container.find('#sort').val()
      per_page: @container.find('#per_page').val()
      loc: @form.find("input#search").val().replace(', United States', '')
      page: page || 1
      start_date: @container.find('input[name="fake_start_date"]').val()
      end_date: @container.find('input[name="fake_end_date"]').val()
      avilability_end: @container.find('input[availability_dates_end]').val()
      avilability_start: @container.find('input[availability_dates_start]').val()
    )
    super

  renderChildCategories: (params_category_ids = []) ->
    category_ids = _.toArray(@container.find('input[name="category_ids[]"]:checked').map(-> $(this).val()))
    Array::push.apply category_ids, params_category_ids
    category_ids = category_ids.join(',')
    @container.find('#categories-children').html('')
    container = @container

    $.ajax(
      url  : '/search/categories'
      type : 'GET',
      data : {category_ids: category_ids },
      success: (data, textStatus, jqXHR) =>
        @container.find('#categories-children').hide().html(data)
        subcategories_parents = []
        @container.find('.categories-children').html('')
        @container.find('#categories-children').find('.search-mixed-filter').each (index, elem) ->
          subcat = $(elem).clone()
          category_id = parseInt(subcat.attr('data-category-id'))
          filter = container.find('input[name="category_ids[]"][value="' + category_id + '"]').closest('.search-mixed-filter')

          new_category = !(filter.get(0) in subcategories_parents)

          if new_category
            newdiv = $("<div class='categories-children'></div>")
            newdiv.append(subcat)

          if filter.next().hasClass('categories-children')
            if new_category
              filter.next().html(newdiv.html())
            else
              filter.next().append(subcat)
          else
            filter.after(newdiv)

          subcategories_parents.push filter.get(0)
        @container.find('#categories-children').html('')
        new CustomInputs()
    )

  updateResultsCount: ->
    count = parseInt(@hiddenResultsContainer().find('input#result_count').val())
    inflection = 'result'
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

      lat = @form.find('input[name=lat]').val()
      lng = @form.find('input[name=lng]').val()

      if lat.length and lng.length
        bounds.extend(new google.maps.LatLng(@form.find('input[name=lat]').val(), @form.find('input[name=lng]').val()))

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
    @setListingCounter()


  # Trigger automatic updating of search results
  fieldChanged: (field, value) ->
    @renderChildCategories()
    @triggerSearchFromQuery()

  autocompleteCategories: ->
    self = this
    if @container.find("input[data-category-autocomplete]").length > 0
      $.each @container.find("input[data-category-autocomplete]"), (index, select) ->
        $(select).select2(
          multiple: true
          initSelection: (element, callback) ->
            url = $(select).attr('data-api-category-path')
            $.getJSON url, { init_selection: 'true', ids: $(select).attr("data-selected-categories") }, (data) ->
              callback data

          ajax:
            url: $(select).attr('data-api-category-path')
            datatype: "json"
            data: (term, page) ->
              per_page: 50
              page: page
              q:
                name_cont: term

            results: (data, page) ->
              results: data

          formatResult: (category) ->
            category.translated_name

          formatSelection: (category) ->
            category.translated_name
        ).on('change', (e) ->
          self.fieldChanged()
        ).select2('val', $(select).attr("data-selected-categories"))


  updateUrlForSearchQuery: ->
    url = document.location.href.replace(/\?.*$/, "")
    params = @getSearchParams()
    filtered_params = []
    for k, param of params
      if $.inArray(param["name"], ['ignore_search_event', 'country', 'v']) < 0
        filtered_params.push {name: param["name"], value: param["value"]}
    if @sortValue != 'relevance'
      filtered_params.push {name: 'sort', value: @sortValue}

    # we need to decodeURIComponent, otherwise accents will not be handled correctly. Remove decodeURICompoent if we switch back
    # to window.history.replaceState, but it's *absolutely mandatory* in this case. Removing it now will lead to infiite redirection in IE lte 9
    url = decodeURIComponent("?#{$.param(filtered_params)}")
    History.replaceState(params, @container.find('input[name=meta_title]').val(), url)


  bindLocationsEvents: ->

    @resultsContainer().find('article.location').on 'mouseleave', (event) =>
      location = $(event.target).closest('article.location')
      @unmarkAllLocations()
      location_id = location.data('id')
      marker = @map.markers[location_id]
      if marker
        marker.setIcon(SearchResultsGoogleMapMarker.getMarkerOptions().default.image)
        marker.setZIndex(google.maps.Marker.MAX_ZINDEX)

    @resultsContainer().find('article.location').on 'mouseenter',(event) =>
      location = $(event.target).closest('article.location')
      @unmarkAllLocations()
      location.addClass('active')
      location_id = location.data('id')
      marker = @map.markers[location_id]
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
    categories_checkboxes = _.toArray(@container.find('input[name="category_ids[]"]:checked').map(-> $(this).val()))
    categories_selects = []
    @container.find('input[name="categories_ids[]"]').each ->
      value = $(this).val()
      if value && value != ''
        values = value.split(',')
        categories_selects = categories_selects.concat(values)

    all_categories = categories_selects.concat(categories_checkboxes)
    price_max = if @container.find('input[name="price[max]"]:checked').length > 0 then @container.find('input[name="price[max]"]:checked').val() else $('input[name="price[max]"]').val()
    @assignFormParams(
      nx: @formatCoordinate(bounds[0]),
      ny: @formatCoordinate(bounds[1]),
      sx: @formatCoordinate(bounds[2]),
      sy: @formatCoordinate(bounds[3]),
      ignore_search_event: 1,
      page: 1,
      category_ids: all_categories.join(','),
      'price[max]': price_max,
      time_from: @container.find('select[name="time_from"]').val(),
      time_to: @container.find('select[name="time_to"]').val(),
      sort: @container.find('select[name="sort"]').val(),
      lntype: _.toArray($('input[name="location_types_ids[]"]:checked').map(-> $(this).val())).join(',')
    )
    custom_attributes = {}
    for custom_attribute in @container.find('div[data-custom-attribute]')
      custom_attribute = $(custom_attribute)
      custom_attributes[custom_attribute.data('custom-attribute')] = _.toArray(custom_attribute.find('input[name="lg_custom_attributes[' + custom_attribute.data('custom-attribute') + '][]"]:checked').map(-> $(this).val())).join(',')
    @assignFormParams(lg_custom_attributes: custom_attributes)

    @mapTrigger = true

    @triggerSearchAndHandleResults =>
      @plotListingResultsWithinBounds()
      @assignFormParams(
        ignore_search_event: 1
      )


  initializeCarousel: ->
    $('.carousel').carousel({ interval: 7000 })

  reinitializePriceSlider: =>
    $('#price-slider').remove()
    $('.price-slider-container').append('<div id="price-slider"></div>')
    super

  setListingCounter: ->
    offset = parseInt @container.find('.search-pagination').data('offset')
    for counter, i in @container.find(".location-counter")
      $(counter).text(i + offset)
