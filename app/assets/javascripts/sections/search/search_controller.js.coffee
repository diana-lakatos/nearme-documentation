# Controller for Search results and filtering page
#
# FIXME: This and the home search form should be separate. Instead we should abstract out
#        a common "search query" input field which handles the geolocation of the query,
#        and notifies observers when it is changed.
class Search.SearchController extends Search.Controller
  constructor: (form, @container) ->
    super(form)
    @resultsContainer = @container.find('.results')
    @loadingContainer = @container.find('.loading')
    @resultsCountContainer = $('#search_results_count')
    @initializeMap()
    @bindEvents()

  bindEvents: ->
    @form.bind 'submit', (event) =>
      event.preventDefault()
      @triggerSearchFromQuery()

    @map.on 'viewportChanged', =>
      # NB: The viewport can change during 'query based' result loading, when the map fits
      #     the bounds of the search results. We don't want to trigger a bounding box based
      #     lookup during a controlled viewport change such as this.
      return if @processingResults
      return unless @redoSearchMapControl.isEnabled()

      @triggerSearchWithBoundsAfterDelay()

  initializeMap: ->
    mapContainer = @container.find('#listings_map')[0]
    return unless mapContainer

    @map = new Search.Map(mapContainer)

    # Add our map viewport search control, which enables/disables searching on map move
    @redoSearchMapControl = new Search.RedoSearchMapControl(enabled: true)
    @map.addControl(@redoSearchMapControl)

    @updateMapWithListingResults()

  startLoading: ->
    @resultsContainer.hide()
    @loadingContainer.show()

  finishLoading: ->
    @loadingContainer.hide()
    @resultsContainer.show()

  showResults: (html) ->
    @resultsContainer.html(html)
    @updateResultsCount()

  updateResultsCount: ->
    count = @resultsContainer.find('.listing:not(.hidden)').length
    inflection = 'result'
    inflection += 's' unless count == 1
    @resultsCountContainer.html("#{count} #{inflection}")

  # Update the map with the current listing results, and adjust the map display.
  updateMapWithListingResults: ->
    @map.resetMapMarkers()
    @map.plotListings(@getListingsFromResults())
    @map.fitBounds()

  # Within the current map display, plot the listings from the current results. Remove listings
  # that aren't within the current map bounds from the results.
  plotListingResultsWithinBounds: ->
    for listing in @getListingsFromResults()
      wasPlotted = @map.plotListingIfInMapBounds(listing)
      listing.hide() unless wasPlotted

    @map.removeListingsOutOfMapBounds()
    @updateResultsCount()

  # Return Search.Listing objects from the search results.
  getListingsFromResults: ->
    listings = []
    @resultsContainer.find('.listing').each (i, el) =>
      listings.push new Search.Listing(el)
    listings

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
        @updateMapWithListingResults()

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
      @showResults(html)
      callback() if callback
      @finishLoading()
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
    @startLoading()
    @triggerSearchFromQueryAfterDelay()

  updateUrlForSearchQuery: ->
    if window.history?.replaceState
      url = document.location.href.replace(/\?.*$/, "")
      url = "#{url}?#{$.param(@getSearchParams())}"
      history.replaceState(params, "Search Results", url)
