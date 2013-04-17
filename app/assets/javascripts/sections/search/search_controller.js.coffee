# Controller for Search results and filtering page
#
# FIXME: This and the home search form should be separate. Instead we should abstract out
#        a common "search query" input field which handles the geolocation of the query,
#        and notifies observers when it is changed.
class Search.SearchController extends Search.Controller
  constructor: (form, @container) ->
    super(form)
    @listings = {}
    @resultsContainer = => @container.find('#results')
    @loadingContainer = => @container.find('.loading')
    @resultsCountContainer = $('#search_results_count')
    @processingResults = true
    @initializeMap()
    @bindEvents()
    @initializeEndlessScrolling()
    setTimeout((=> @processingResults = false), 1000)

  bindEvents: ->
    @form.bind 'submit', (event) =>
      event.preventDefault()
      @triggerSearchFromQuery()
    
    @searchField = @form.find('#search')
    
    @searchField.on 'focus', => $(@form).addClass('query-active')
    @searchField.on 'blur', => $(@form).removeClass('query-active')
    
    if @map?
      @map.on 'click', =>
        @searchField.blur()
      
      @map.on 'viewportChanged', =>
        # NB: The viewport can change during 'query based' result loading, when the map fits
        #     the bounds of the search results. We don't want to trigger a bounding box based
        #     lookup during a controlled viewport change such as this.
        return if @processingResults
        return unless @redoSearchMapControl.isEnabled()
      
        @triggerSearchWithBoundsAfterDelay()
  
  initializeEndlessScrolling: ->
    $('#results').scrollTop(0)
    jQuery.ias({
      container : '#results',
      item: '.listing',
      pagination: '.pagination',
      next: '.next_page',
      triggerPageThreshold: 50,
      history: false,
      thresholdMargin: -90,
      loader: '<h1><img src="' + $('img[alt=Spinner]').eq(0).attr('src') + '"><span>Loading More Results</span></h1>',
      onRenderComplete: (items) ->
        for item in items
          new HeightConstrainer( $('article.listing[data-id='+item.getAttribute("data-id")+'] .details-container'), $('article.listing[data-id='+item.getAttribute("data-id")+'] .photo-container'), { ratio: 254/410 })
    })

  initializeMap: ->
    mapContainer = @container.find('#listings_map')[0]
    return unless mapContainer

    @map = new Search.Map(mapContainer)

    # Add our map viewport search control, which enables/disables searching on map move
    @redoSearchMapControl = new Search.RedoSearchMapControl(enabled: true)
    @map.addControl(@redoSearchMapControl)
    
    resizeMapThrottle = _.throttle((=> @map.resizeToFillViewport()), 200)
    
    $(window).resize resizeMapThrottle
    $(window).trigger('resize')
    
    @updateMapWithListingResults()

  startLoading: ->
    @loadingContainer().show()

  finishLoading: ->
    @loadingContainer().hide()

  showResults: (html) ->
    @resultsContainer().replaceWith(html)

  updateResultsCount: ->
    count = @resultsContainer().find('.listing:not(.hidden)').length
    inflection = 'result'
    inflection += 's' unless count == 1
    @resultsCountContainer.html("#{count} #{inflection}")
  
  # Update the map with the current listing results, and adjust the map display.
  updateMapWithListingResults: ->
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
    listing = @listings[id] ?= Search.Listing.forElement(element)
    listing.setElement(element)
    listing

  # Triggers a search request with the current map bounds as the geo constraint
  triggerSearchWithBounds: ->
    bounds = @map.getBoundsArray()
    @assignFormParams(
      nx: @formatCoordinate(bounds[0]),
      ny: @formatCoordinate(bounds[1]),
      sx: @formatCoordinate(bounds[2]),
      sy: @formatCoordinate(bounds[3])
    )

    @triggerSearchAndHandleResults =>
      @plotListingResultsWithinBounds()

  # Provide a debounced method to trigger the search after a period of constant state
  triggerSearchWithBoundsAfterDelay: _.debounce(->
    @triggerSearchWithBounds()
  , 300)

  # Trigger the search from manipulating the query.
  # Note that the behaviour semantics are different to manually moving the map.
  triggerSearchFromQuery: ->
    @startLoading()
    @geocodeSearchQuery =>
      @triggerSearchAndHandleResults =>
        @updateMapWithListingResults() if @map?

  # Trigger the search after waiting a set time for further updated user input/filters
  triggerSearchFromQueryAfterDelay: _.debounce(->
    @triggerSearchFromQuery()
  , 2000)

  # Triggers a search with default UX behaviour and semantics.
  triggerSearchAndHandleResults: (callback) ->
    @startLoading()
    @triggerSearchRequest().success (html) =>
      @processingResults = true
      @updateUrlForSearchQuery()
      @updateLinksForSearchQuery()
      @showResults(html)
      callback() if callback
      @finishLoading()
      @processingResults = false
      @initializeEndlessScrolling()


  # Trigger the API request for search
  #
  # Returns a jQuery Promise object which can be bound to execute response semantics.
  triggerSearchRequest: ->
    $.ajax(
      url  : @form.attr("src")
      type : 'GET',
      data : @form.serialize()
    )

  # Trigger automatic updating of search results
  fieldChanged: (field, value) ->
    @startLoading()
    @triggerSearchFromQueryAfterDelay()

  updateUrlForSearchQuery: ->
    if window.history?.replaceState
      url = document.location.href.replace(/\?.*$/, "")
      params = @getSearchParams()
      url = "#{url}?#{$.param(params)}"
      history.replaceState(params, "Search Results", url)

  updateLinksForSearchQuery: ->
    url = document.location.href.replace(/\?.*$/, "")
    params = @getSearchParams()

    $('.list-map-toggle a', @form).each ->
      _params = $.extend(params, { v: (if $(this).hasClass('map') then 'map' else 'list') })
      _url = "#{url}?#{$.param(_params)}"
      $(this).attr('href', _url)
    
