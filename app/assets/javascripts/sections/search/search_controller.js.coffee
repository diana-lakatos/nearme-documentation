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

  initializeMap: ->
    mapContainer = @container.find('#listings_map')[0]
    return unless mapContainer
    @map = new Map(mapContainer)
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
    @finishLoading()
    @updateMapWithListingResults()

  updateListingsCount: () ->
    if(typeof @resultsCountContainer != 'undefined')
      count = @resultsContainer.find('.listing').length
      listing_text = "listing"
      if(count != 1)
        listing_text += "s"
      @resultsCountContainer.html(count + " " + listing_text )
  
  updateMapWithListingResults: ->
    listings = []
    @resultsContainer.find('.listing').each (i, el) =>
      el = $(el)
      listings.push(
        id:        parseInt(el.attr('data-id'), 10),
        latitude:  parseFloat(el.attr('data-latitude')),
        longitude: parseFloat(el.attr('data-longitude')),
        name:      el.attr('data-name'),
        element:   el
      )

    @map.plotListings(listings)

  triggerSearch: ->
    @startLoading()

    @geocodeSearchQuery =>
      $.ajax(
        url     : @form.attr("src")
        type    : 'GET',
        data    : @form.serialize(),
        success : (html) => @showResults(html)
      )

  # Trigger the search after waiting a set time for further updated user input/filters
  triggerSearchAfterDelay: _.debounce(-> 
    @triggerSearch()
  , 2000)

  # Trigger automatic updating of search results
  fieldChanged: (field, value) ->
    @startLoading()
    @triggerSearchAfterDelay()

  # Encapsulates the map behaviour for the serach results
  class Map
    constructor: (@container) ->
      @markers = []
      @infoWindow = new google.maps.InfoWindow() 
      @googleMap = new google.maps.Map(@container, {
        zoom: 8,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControl: false
      })
      @clearPlottedListings()

      $(window).resize =>
        google.maps.event.trigger(@googleMap, 'resize') 
        @fitBounds()

    clearPlottedListings: ->
      marker.setMap(null) for marker in @markers if @markers
      @markers = []
      @bounds = new google.maps.LatLngBounds()

    plotListings: (listings, clearPreviousPlot = true) ->
      @clearPlottedListings() if clearPreviousPlot
      @plotListing(listing) for listing in listings
      @fitBounds()

    plotListing: (listing) ->
      latLng = new google.maps.LatLng(listing.latitude, listing.longitude)
      marker = new google.maps.Marker(
        position: latLng,
        map:      @googleMap,
        title:    listing.name
      )
      @markers.push(marker)
      @bounds.extend(latLng)

      # Bind the event for showing the info details on click
      if listing.element
        google.maps.event.addListener marker, 'click', =>
          @showInfoWindowForListing(listing, marker)

    fitBounds: ->
      @googleMap.fitBounds(@bounds)

    showInfoWindowForListing: (listing, marker) ->
      popupContent = $('.listing-info', listing.element).html()
      @infoWindow.setContent(popupContent)
      @infoWindow.open(@googleMap, marker)     

