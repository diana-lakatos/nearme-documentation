# Controller for Search results and filtering page
class Search.SearchController extends Search.Controller
  constructor: (form, @container) ->
    super(form)
    @resultsContainer = @container.find('.results')
    @loadingContainer = @container.find('.loading')
    @resultsCountContainer = $('#results_count')
    @initializeMap()
    @bindEvents()

  bindEvents: ->
    @form.bind 'submit', (event) =>
      event.preventDefault()
      @triggerSearch()

    @map.on 'viewportChanged', =>
      @triggerSearchWithBoundsAfterDelay()

  initializeMap: ->
    mapContainer = @container.find('#listings_map')[0]
    return unless mapContainer
    @map = new Search.Map(mapContainer)
    @updateMapWithListingResults()

  startLoading: ->
    @resultsContainer.hide()
    @loadingContainer.show()

  finishLoading: ->
    @loadingContainer.hide()
    @resultsContainer.show()

  showResults: (html) ->
    @resultsContainer.html(html)
    @updateListingsCount()

  updateListingsCount: () ->
    if(typeof @resultsCountContainer != 'undefined')
      count = @resultsContainer.find('.listing').length
      listing_text = "listing"
      if(count != 1)
        listing_text += "s"
      @resultsCountContainer.html(count + " " + listing_text )
  
  # Update the map with the current listing results, and adjust the map display.
  updateMapWithListingResults: ->
    @map.clearPlottedListings()
    @map.plotListings(@getListingsFromResults())
    @map.fitBounds()

  # Within the current map display, plot the listings from the current results. Remove listings
  # that aren't within the current map bounds from the results.
  plotListingResultsWithinBounds: ->
    for listing in @getListingsFromResults()
      wasPlotted = @map.plotListingIfInMapBounds(listing)
      listing.hide() unless wasPlotted
        
    @map.removeListingsOutOfMapBounds()

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
      nx: bounds[0],
      ny: bounds[1],
      sx: bounds[2],
      sy: bounds[3]
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
      @showResults(html)
      callback() if callback
      @finishLoading()

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
