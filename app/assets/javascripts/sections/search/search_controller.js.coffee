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

    # TODO: Limit the zoom range for the serach we make as to not ask for rediculous levels of listings
    # What is that zoom range?
    @map.on 'mapDragged', =>
      @triggerSearchWithBoundsAfterDelay()

  initializeMap: ->
    mapContainer = @container.find('#listings_map')[0]
    return unless mapContainer
    @map = new Search.Map(mapContainer)
    @updateMapWithListingResults()
    @map.fitBounds()

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
  
  updateMapWithListingResults: ->
   @map.clearPlottedListings()
   @map.plotListings(@getListingsFromResults())
   @map.fitBounds()

  getListingsFromResults: ->
    listings = []
    @resultsContainer.find('.listing').each (i, el) =>
      listings.push new Search.Listing(el)
    listings

  triggerSearchWithBounds: ->
    bounds = @map.getBoundsArray()
    @assignFormParams(
      nx: bounds[0],
      ny: bounds[1],
      sx: bounds[2],
      sy: bounds[3]
    )

    search = @triggerSearch()
    search.success (html) =>
      @showResults(html)
      for listing in @getListingsFromResults()
        unless @map.plotListingIfInMapBounds(listing)
          listing.hide()
      @map.removeListingsOutOfMapBounds()
      @finishLoading()

  # Provide a debounced method to trigger the search after a period of constant state
  triggerSearchWithBoundsAfterDelay: _.debounce(->
    @triggerSearchWithBounds()
  , 300)

  # Trigger the search from manipulating the query.
  # Note that the behaviour semantics are different to manually moving the map.
  triggerSearchFromQuery: ->
    @startLoading()
    @geocodeSearchQuery =>
      search = @triggerSearch()
      search.success (html) =>
        @showResults(html)
        @updateMapWithListingResults()
        @finishLoading()
        @map.fitBounds()

  # Trigger search
  #
  # Returns a jQuery Promise object which can be bound to execute response semantics.
  triggerSearch: ->
    @startLoading()

    $.ajax(
      url     : @form.attr("src")
      type    : 'GET',
      data    : @form.serialize()
    )

  # Trigger the search after waiting a set time for further updated user input/filters
  triggerSearchFromQueryAfterDelay: _.debounce(-> 
    @triggerSearchFromQuery()
  , 2000)

  # Trigger automatic updating of search results
  fieldChanged: (field, value) ->
    @startLoading()
    @triggerSearchFromQueryAfterDelay()



