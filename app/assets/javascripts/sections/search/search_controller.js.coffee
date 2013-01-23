# Controller for Search results and filtering
class Search.SearchController extends Search.Controller
  constructor: (form, @container) ->
    super(form)
    @resultsContainer = @container.find('.results')
    @loadingContainer = @container.find('.loading')
    @loadMap()

  bindEvents: ->
    @form.bind 'submit', (event) =>
      event.preventDefault()
      @triggerSearch()

  startLoading: ->
    @resultsContainer.hide()
    @loadingContainer.show()

  finishLoading: ->
    @loadingContainer.hide()
    @resultsContainer.show()

  showResults: (html) ->
    @resultsContainer.html(html)
    @finishLoading()
    @loadMap()

  listings: ->
    @resultsContainer.find('.listing')
    
  loadMap: ->
    mapContainer = @container.find('#listings_map')[0]
    return unless mapContainer

    @map = {}
    @map.map = new google.maps.Map(mapContainer, {
      zoom: 8,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      mapTypeControl: false
    })

    @map.bounds = new google.maps.LatLngBounds()
    @map.markers = {}
    @map.info_window = new google.maps.InfoWindow()

    @listings().each (i, el) =>
      el = $(el)
      @plotListing(
        id:        parseInt(el.attr('data-id'), 10),
        latitude:  parseFloat(el.attr('data-latitude')),
        longitude: parseFloat(el.attr('data-longitude')),
        name:      el.attr('data-name'),
        element:   el
      )

    # Update the map bounds based on the plotted listings
    @map.map.fitBounds(@map.bounds)

  plotListing: (listing) ->
    ll = new google.maps.LatLng(listing.latitude, listing.longitude)
    @map.bounds.extend(ll)
    @map.markers[listing.id] = new google.maps.Marker(
      position: ll,
      map:      @map.map,
      title:    listing.name
    )

    if listing.element
      popupContent = $('.listing-info', listing.element).html()
      google.maps.event.addListener @map.markers[listing.id], 'click', =>
        @map.info_window.setContent(popupContent)
        @map.info_window.open(@map.map, @map.markers[listing.id])

  triggerSearch: ->
    @startLoading()

    deferred = @geocoder.geocodeAddress(@queryField.val())
    deferred.always (results) =>
      if results
        result = results.getBestResult()
        lat = result.lat()
        lng = result.lng()
        bb  = result.boundingBox()
      else
        lat = null
        lng = null

      @form.find('input[name*=lat]').val(lat)
      @form.find('input[name*=lng]').val(lng)
      @form.find('input[name*=nx]').val(bb[0])
      @form.find('input[name*=ny]').val(bb[1])
      @form.find('input[name*=sx]').val(bb[2])
      @form.find('input[name*=sy]').val(bb[3])


      $.ajax(
        url     : @form.attr("src")
        type    : 'GET',
        data    : @form.serialize(),
        success : (html) => @showResults(html)
      )

  # Trigger automatic updating of search results
  fieldChanged: (field, value) ->
    clearTimeout(@searchTriggerTimeout) if @searchTriggerTimeout
    @startLoading()
    @searchTriggerTimeout = setTimeout(
      => @triggerSearch(),
      2000
    )