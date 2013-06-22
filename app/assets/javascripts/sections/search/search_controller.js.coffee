# Controller for Search results and filtering page
#
# FIXME: This and the home search form should be separate. Instead we should abstract out
#        a common "search query" input field which handles the geolocation of the query,
#        and notifies observers when it is changed.
class Search.SearchController extends Search.Controller
  constructor: (form, @container) ->
    super(form)
    @initializeDateRangeField()

    @listings = {}
    @resultsContainer = => @container.find('#results')
    @loader = new Search.ScreenLockLoader => @container.find('.loading')
    @resultsCountContainer = $('#search_results_count')
    @processingResults = true
    @initializeMap()
    @bindEvents()
    @initializeEndlessScrolling()
    @reinitializeEndlessScrolling = false
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
  
  initializeDateRangeField: ->
    @startDatepicker = new window.Datepicker(
      trigger: @form.find('.availability-date-start'),
      positionTarget: @form.find('.availability-date-start input'),
      text: '<div class="datepicker-text-fadein">Select a start date</div>',

      # Limit to a single date selected at a time
      model: new window.Datepicker.Model.Single(
        allowDeselection: true
      )
    )

    @endDatepicker = new window.Datepicker(
      view: new Search.SearchRangeDatepickerView(@startDatepicker,
        positionTarget: @form.find('.availability-date-end input'),
        text: '<div class="datepicker-text-fadein">Select an end date</div>'
      ),

      # Limit to a single date selected at a time
      model: new window.Datepicker.Model.Single(
        allowDeselection: false
      )
    )

    @startDatepicker.on 'datesChanged', =>
      @startDatepickerChanged()
    
    @endDatepicker.on 'datesChanged', =>
      @updateDateFields()

    @form.find('.availability-date-end').on 'click', (e) =>
      if @startDatepicker.getDates()[0]
        @startDatepicker.hide()
        @endDatepicker.toggle()
      else
        @startDatepicker.show()

      e.stopPropagation()
      false

  updateDateFields: ->
    formatDate = (date) ->
      if date
        "#{DNM.util.Date.monthName(date, 3)} #{date.getDate()}"
      else
        ""

    startDate = formatDate @startDatepicker.getDates()[0]
    endDate   = formatDate @endDatepicker.getDates()[0]

    @form.find('.availability-date-start input').val(startDate)
    @form.find('.availability-date-end input').val(endDate)
    @dateRangeFieldChanged([startDate, endDate])

  startDatepickerChanged: ->
    @startDatepicker.hide()

    if startDate = @startDatepicker.getDates()[0]
      endDate = @endDatepicker.getDates()[0]
      if !endDate or endDate.getTime() < startDate.getTime()
        @endDatepicker.setDates([startDate])

      @endDatepicker.show()
    else
      # Deselection
      @endDatepicker.setDates([])

    @updateDateFields()

  dateRangeFieldChanged: (values) ->
    @fieldChanged('dateRange', values)

  initializeEndlessScrolling: ->
    $('#results').scrollTop(0)
    jQuery.ias({
      container : '#results',
      item: '.listing',
      pagination: '.pagination',
      next: '.next_page',
      triggerPageThreshold: 99,
      history: false,
      thresholdMargin: -90,
      loader: '<h1><img src="' + $('img[alt=Spinner]').eq(0).attr('src') + '"><span>Loading More Results</span></h1>',
      onRenderComplete: (items) ->
        for item in items
          new HeightConstrainer( $('article.listing[data-id='+item.getAttribute("data-id")+'] .details-container'), $('article.listing[data-id='+item.getAttribute("data-id")+'] .photo-container'), { ratio: 254/410 })
        # when there are no more resuls, add special div element which tells us, that we need to reinitialize ias - it disables itself on the last page...
        if !$('#results .pagination .next_page').attr('href')
          $('#results').append('<div id="reinitialize"></div>')
          reinitialize = $('#reinitialize')
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

  showResults: (html) ->
    @resultsContainer().replaceWith(html)
    $('.pagination').hide()

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
    @loader.showWithoutLocker()
     # Infinite-Ajax-Scroller [ ias ] which we use disables itself when there are no more results
     # we need to reenable it when it is necessary, and only then - otherwise we will get duplicates
    if $('#reinitialize').length > 0
      @initializeEndlessScrolling()
    @geocodeSearchQuery =>
      @triggerSearchAndHandleResults =>
        @updateMapWithListingResults() if @map?

  # Trigger the search after waiting a set time for further updated user input/filters
  triggerSearchFromQueryAfterDelay: _.debounce(->
    @triggerSearchFromQuery()
  , 2000)

  # Triggers a search with default UX behaviour and semantics.
  triggerSearchAndHandleResults: (callback) ->
    @loader.showWithoutLocker()
    @triggerSearchRequest().success (html) =>
      @processingResults = true
      @updateUrlForSearchQuery()
      @updateLinksForSearchQuery()
      @showResults(html)
      @loader.hide()
      callback() if callback
      @processingResults = false

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
    @loader.show()
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
    
