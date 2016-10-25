require('history.js/history')
require('history.js/history.adapter.ender')

SearchController = require('./controller')
SearchScreenLockLoader = require('./screen_lock_loader');
SearchResultsGoogleMapController = require('./search_results_google_map_controller')
SearchRangeDatePickerFilter = require('./range_datepicker_filter')
SearchRedoSearchMapControl = require('./redo_search_map_control')
SearchListing = require('./listing')
SearchMap = require('./map')
urlUtil = require('../../lib/utils/url');
window.IASCallbacks = require('exports?IASCallbacks!../../vendor/jquery-ias/callbacks')
require('../../vendor/jquery-ias/jquery-ias')

# Controller for Search results and filtering page
#
# FIXME: This and the home search form should be separate. Instead we should abstract out
#        a common "search query" input field which handles the geolocation of the query,
#        and notifies observers when it is changed.
module.exports = class SearchSearchController extends SearchController
  constructor: (form, @container) ->
    super(form, @container)
    @redirectIfNecessary()
    @initializeDateRangeField()

    @listings = {}
    @resultsContainer ||= => @container.find('#results')
    @loader = new SearchScreenLockLoader => @container.find('.loading')
    @resultsCountContainer = $('#search_results_count')
    @transactable_types = $('div[data-transactable-type-filter] input')
    @date_range = $('div[data-date-range-filter] input')
    @date_range_btn = $('div[data-date-range-filter] div[data-date-range-filter-update]')
    @filters = $('a[data-search-filter]')
    @filters_container = $('[data-search-filters-container]')
    @movableGoogleMap = $('#search-result-movable-google-map')
    if @movableGoogleMap.length > 0
      new SearchResultsGoogleMapController(@resultsContainer(), @movableGoogleMap);
    @processingResults = true
    @initializeMap()
    @bindEvents()
    @initializeEndlessScrolling()
    @initializeConnectionsTooltip()
    setTimeout((=> @processingResults = false), 1000)
    @responsiveCategoryTree()
    @updateLinks()

    if $('.load-more', @container).length
      @initLoadMoreButton()

  bindEvents: ->
    @form.bind 'submit', (event) =>
      event.preventDefault()
      @triggerSearchFromQuery()

    @transactable_types.on 'change', (event) =>
      @form.find('input[name="transactable_type_id"]').val($(event.target).val())
      params = decodeURIComponent("?#{$.param(@getSearchParams())}")
      document.location = window.location.href = "#{document.location.protocol}//#{document.location.host}#{document.location.pathname}#{params}"

    @date_range_btn.on 'click', (event) =>
      @triggerSearchFromQuery()

    @closeFilterIfClickedOutside()

    @filters.on 'click', (event) =>
      # allow to hide already opened element
      if $(event.currentTarget).parent().find('ul').is(':visible')
        @hideFilters()
      else
        @hideFilters()
        $(event.target).closest('.search-filter').find('ul').toggle()
        $(event.target).closest('.search-filter').toggleClass('active')
      false

    @filters_container.on 'click', 'input[type=checkbox]:not(.nav-heading > label > input), input[type=radio]', (event) =>
      if $(event.target).attr('name') == 'parent_category_ids[]'
        return
      @fieldChanged()

    @filters_container.on 'change', 'input[type=text], select', =>
      @fieldChanged()

    @searchField = @form.find('#search')
    @searchField.on 'focus', => $(@form).addClass('query-active')
    @searchField.on 'blur', => $(@form).removeClass('query-active')

    if @map?
      @bindMapEvents()


  bindMapEvents: =>
    @map.on 'click', =>
      @searchField.blur()

    @map.on 'viewportChanged', =>

      # NB: The viewport can change during 'query based' result loading, when the map fits
      #     the bounds of the search results. We don't want to trigger a bounding box based
      #     lookup during a controlled viewport change such as this.
      return if @processingResults
      return unless @redoSearchMapControl.isEnabled()

      @triggerSearchWithBoundsAfterDelay()

  hideFilters: ->
    for filter in @filters
      $(filter).parent().find('ul').hide()
      $(filter).parent().removeClass('active')

  closeFilterIfClickedOutside: ->
    $('body').on 'click', (event) =>
      if $(@filters_container).has(event.target).length == 0
        @hideFilters()
  # for browsers without native html 5 support for history [ mainly IE lte 9 ] the url looks like:
  # /search?q=OLDQUERY#search?q=NEWQUERY. Initially, results are loaded for OLDQUERY.
  # This methods checks, if OLDQUERY == NEWQUERY, and if not, it redirect to the url after #
  # [ which is stored in History.getState() and contains NEWQUERY ].
  # Updating the form instead of redirecting could be a little bit better,
  # but there are issues with updating google maps view etc. - remember to check it if you update the code
  redirectIfNecessary: ->
    if History.getState() && !window.history?.replaceState
      for k, param of History.getState().data
        if param.name == 'loc'
          if param.value != urlUtil.getParameterByName('loc')
            document.location = History.getState().url


  initializeDateRangeField: ->
    @rangeDatePicker = new SearchRangeDatePickerFilter(
      @form.find('.availability-date-start'),
      @form.find('.availability-date-end'),
      (dates) => @fieldChanged('dateRange', dates)
    )

  initializeEndlessScrolling: ->
    $('#results').scrollTop(0)

    ias = jQuery.ias({
      container : '#results',
      item: '.listing',
      pagination: '.pagination',
      next: '.next_page',
      triggerPageThreshold: 99,
      history: false,
      thresholdMargin: -90,
      loader: '<div class="row-fluid span12"><h1><img src="' + $('img[alt=Spinner]').eq(0).attr('src') + '"><span>Loading More Results</span></h1></div>',
      onRenderComplete: (items) =>
        @initializeConnectionsTooltip()
    })

    ias.on 'rendered', (items)->
      $(document).trigger('rendered-search:ias.nearme', [items])

  initializeMap: ->
    mapContainer = @container.find('#listings_map')[0]
    return unless mapContainer
    @map = new SearchMap(mapContainer, this)

    # Add our map viewport search control, which enables/disables searching on map move
    @redoSearchMapControl = new SearchRedoSearchMapControl(enabled: true, update_text: $(mapContainer).data('update-text'))
    @map.addControl(@redoSearchMapControl)

    resizeMapThrottle = _.throttle((=> @map.resizeToFillViewport()), 200)

    $(window).resize resizeMapThrottle
    $(window).trigger('resize')

    @updateMapWithListingResults()

  showResults: (html) ->
    wrap = $('<div>' + html + '</div>')
    html = wrap.find('#results')
    @resultsContainer().replaceWith(html)
    @resultsContainer().find("input[data-authenticity-token]").val($('meta[name="authenticity_token"]').attr('content'));
    $('.pagination').hide()
    @updateResultsCount()

  updateResultsCount: ->
    count = @resultsContainer().find('.listing:not(.hidden)').length
    inflection = 'result'
    inflection += 's' unless count == 1
    @resultsCountContainer.html("<b>#{count}</b> #{inflection}")

  # Update the map with the current listing results, and adjust the map display.
  updateMapWithListingResults: ->
    @map.popover.close()

    listings = @getListingsFromResults()

    if listings? and listings.length > 0
      @map.plotListings(listings)

      # Only show bounds of new results
      bounds = new google.maps.LatLngBounds()
      bounds.extend(listing.latLng()) for listing in listings
      bounds.extend(new google.maps.LatLng(@form.find('input[name=lat]').val(), @form.find('input[name=lng]').val()))
      _.defer => @map.fitBounds(bounds)

      @map.show()

      # In case the map is hidden
      @map.resizeToFillViewport()
    else
      @map.hide()

  # Within the current map display, plot the listings from the current results. Remove listings
  # that aren't within the current map bounds from the results.
  plotListingResultsWithinBounds: ->
    for listing in @getListingsFromResults()
      wasPlotted = @map.plotListingIfInMapBounds(listing)
      listing.hide() unless wasPlotted

    @updateResultsCount()

  # Return Search.Listing objects from the search results.
  getListingsFromResults: ->
    listings = []
    @resultsContainer().find('.listing').each (i, el) =>
      listing = @listingForElementOrBuild(el)
      listings.push listing
    listings

  # Initialize or build a Search.Listing object from the DOM element.
  # Handles memoizing by listing ID and swapping the backing DOM element
  # for the leasting from search result refreshes/changes.
  #
  # TODO: Migrate to generating the result HTML elements client-side so we can
  #       avoid this complexity.
  listingForElementOrBuild: (element) ->
    id = $(element).attr('data-id')
    listing = @listings[id] ?= SearchListing.forElement(element)
    listing.setElement(element)
    listing

  # Triggers a search request with the current map bounds as the geo constraint
  triggerSearchWithBounds: ->
    bounds = @map.getBoundsArray()
    @assignFormParams(
      nx: @formatCoordinate(bounds[2]),
      ny: @formatCoordinate(bounds[3]),
      sx: @formatCoordinate(bounds[0]),
      sy: @formatCoordinate(bounds[1]),
      ignore_search_event: 1
    )

    @mapTrigger = true

    @triggerSearchAndHandleResults =>
      @plotListingResultsWithinBounds()
      @assignFormParams(
        ignore_search_event: 1
      )

  # Provide a debounced method to trigger the search after a period of constant state
  triggerSearchWithBoundsAfterDelay: _.debounce(->
    @triggerSearchWithBounds()
  , 300)

  # Trigger the search from manipulating the query.
  # Note that the behaviour semantics are different to manually moving the map.
  triggerSearchFromQuery: (page = false) ->
    # we want to log any new search query
    categories_checkboxes = _.toArray(@container.find('input[name="category_ids[]"]:checked').map(-> $(this).val()))
    category_selects = _.toArray(@container.find('select[name="category_ids[]"] option:selected').map(-> $(this).val() if $(this).val()))
    category_inputs = []
    @container.find('input[name="categories_ids[]"]').each ->
      value = $(this).val()
      if value && value != ''
        values = value.split(',')
        category_inputs = category_inputs.concat(values)

    all_categories = category_inputs.concat(categories_checkboxes, category_selects)
    @mapTrigger = false if (!page or parseInt($(page).val()) == 1)

    price_max = if @container.find('input[name="price[max]"]:checked').length > 0 then @container.find('input[name="price[max]"]:checked').val() else $('input[name="price[max]"]').val()

    @assignFormParams(
      'price[max]': price_max
      time_from: @container.find('select[name="time_from"]').val()
      time_to: @container.find('select[name="time_to"]').val()
      time_to: @container.find('select[name="time_to"]').val()
      sort: @container.find('select[name="sort"]').val()
      ignore_search_event: 0
      category_ids: all_categories.join(',')
      lntype: _.toArray($('input[name="location_types_ids[]"]:checked').map(-> $(this).val())).join(',')
    )
    custom_attributes = {}
    for custom_attribute in @container.find('[data-custom-attribute]')
      custom_attribute = $(custom_attribute)
      custom_attributes[custom_attribute.data('custom-attribute')] = _.toArray(custom_attribute.find('input[name="lg_custom_attributes[' + custom_attribute.data('custom-attribute') + '][]"]:checked').map(-> $(this).val())).join(',')
    @assignFormParams(lg_custom_attributes: custom_attributes)
    @loader.showWithoutLocker()
     # Infinite-Ajax-Scroller [ ias ] which we use disables itself when there are no more results
     # we need to reenable it when it is necessary, and only then - otherwise we will get duplicates

    @geocodeSearchQuery =>
      @triggerSearchAndHandleResults =>
        if $.ias
          $.ias('destroy')
          @initializeEndlessScrolling()

        @movableGoogleMap = $('#search-result-movable-google-map').get(0)
        new SearchResultsGoogleMapController(@resultsContainer(), @movableGoogleMap) if @movableGoogleMap?
        @updateMapWithListingResults() if @map?
        @updateLinks()


  # Trigger the search after waiting a set time for further updated user input/filters
  triggerSearchFromQueryAfterDelay: _.debounce(->
    @triggerSearchFromQuery()
  , 500)

  # Triggers a search with default UX behaviour and semantics.
  triggerSearchAndHandleResults: (callback) ->
    @loader.showWithoutLocker()
    @triggerSearchRequest().success (html) =>
      @processingResults = true
      @showResults(html)
      @updateUrlForSearchQuery()
      @updateLinksForSearchQuery()
      # This was commented out for UoT purpose, as I couldn't imagine why it is necessary to change user position on page
      # window.scrollTo(0, 0) if !@map
      @reinitializePriceSlider()
      @loader.hide()
      callback() if callback
      _.defer => @processingResults = false

      $(document).trigger('load:searchResults.nearme');

  # Trigger the API request for search
  #
  # Returns a jQuery Promise object which can be bound to execute response semantics.
  triggerSearchRequest: ->
    data = @form.serializeArray()
    data.push({"name": "map_moved", "value": @mapTrigger})
    $.ajax(
      url  : @form.attr("action")
      type : 'GET',
      data : $.param(data)
    )

  updateListings: (listings, callback, error_callback = ->) ->
    @triggerListingsRequest(listings).success (html) =>
      html = "<div>" + html + "</div>"
      listing.setHtml($('article[data-id="' + listing.id() + '"]', html)) for listing in listings
      callback() if callback
    .error () =>
      error_callback() if error_callback

  updateListing: (listing, callback) ->
    @triggerListingsRequest([listing]).success (html) =>
      listing.setHtml(html)
      callback() if callback

  triggerListingsRequest: (listings) =>
    listing_ids = (listing.id() for listing in listings).toString()
    $.ajax(
      url  : '/search/show/' + listing_ids + '?v=map'
      type : 'GET'
    )

  # Trigger automatic updating of search results
  fieldChanged: (field, value) ->
    @triggerSearchFromQueryAfterDelay()

  updateUrlForSearchQuery: ->
    url = document.location.href.replace(/\?.*$/, "")
    params = @getSearchParams()
    # we need to decodeURIComponent, otherwise accents will not be handled correctly. Remove decodeURICompoent if we switch back
    # to window.history.replaceState, but it's *absolutely mandatory* in this case. Removing it now will lead to infiite redirection in IE lte 9
    url = decodeURIComponent("?#{$.param(params)}")
    History.replaceState(params, "Search Results", url)

  updateLinksForSearchQuery: ->
    url = document.location.href.replace(/\?.*$/, "")
    params = @getSearchParams()

    $('.list-map-toggle a', @form).each ->
      view = $(this).data('view')
      for k, param of params
        if param["name"] == 'v'
          param["value"] = view
      _url = "#{url}?#{$.param(params)}&ignore_search_event=1"
      $(this).attr('href', _url)

  initializeConnectionsTooltip: ->
    @container.find('.connections:not(.initialized)').addClass('iinitialized').tooltip(html: true, placement: 'top')

  updateLinks: ->
    if @date_range.length > 1
      $("div.locations a:not(.carousel-control)").each (index, link)=>
        return if $(link).closest('.pagination').length > 0
        href = link.href.replace(/\?.*$/, "")
        href += "?start_date=#{@date_range[0].value}&end_date=#{@date_range[1].value}"
        link.href = href

  initLoadMoreButton: ->
    @container.on 'click', '.load-more', (event) =>
      event.preventDefault()

      nextPage = $(event.target).data('next-page')

      if(nextPage)
        $("input[name='page']", @form).val(nextPage)
        @triggerSearchFromQuery()
