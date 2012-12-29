# New search functionality implementation.
#
#
class DNM.SearchForm
  constructor: (@form) ->
    @initializeFields()
    @initializeGeolocateButton()

  # Initialize all filters for the search form
  initializeFields: ->
    @priceRange = new PriceRange(@form.find('.price-range'), 300, @)
    @initializeAvailabilityQuantityFilter()
    @initializeQueryField()
    @initializeAmenitiesField()
    @initializeAssociationsField()
    @initializeDateRangeField()

  availabilityQuantityChanged: (value) ->
    @availabilityQuantityField = @form.find('.availability-quantity input').val(value)
    @form.find('.availability-quantity .value').text(value)
    @fieldChanged('availability-quantity', value)

  dateRangeFieldChanged: (values) ->
    @fieldChanged('dateRange', values)

  amenitiesChanged: ->
    @fieldChanged('amenities')

  associationsChanged: ->
    @fieldChanged('associations')

  fieldChanged: (filter, value) ->
    # Override to trigger automatic updating etc.

  initializeQueryField: ->
    @queryField = @form.find('input.query')
    if @queryField.val() == ''
      _.defer(=>@geolocateMe())

    @queryField.bind 'change', =>
      @fieldChanged('query', @queryField.val())

    # TODO: Trigger fieldChanged on keypress after a few seconds timeout?

  initializeAmenitiesField: ->
    @form.find('.amenities .multiselect').on 'change', =>
      @amenitiesChanged()

  initializeAssociationsField: ->
    @form.find('.associations .multiselect').on 'change', =>
      @associationsChanged()

  initializeDateRangeField: ->
    @form.find('.availability-date-start input, .availability-date-end input').datepicker(
      dateFormat: 'd M'
    ).change (event) =>
      values = [@form.find('.availability-date-start input').val(), @form.find('.availability-date-end input').val()]
      @dateRangeFieldChanged(values)

    # Hack to only apply jquery-ui theme to datepicker
    $('#ui-datepicker-div').wrap('<div class="jquery-ui-theme" />')

    @form.find('.availability-date-start .calendar').on 'click', =>
      @form.find('.availability-date-start input').datepicker('show')

    @form.find('.availability-date-end .calendar').on 'click', =>
      @form.find('.availability-date-end input').datepicker('show')

  initializeAvailabilityQuantityFilter: ->
    @slider = @form.find(".availability-quantity .slider")
    return unless @slider.length > 0
    @slider.slider(
      value: @form.find('.availability-quantity input').val(), min  : 1, max  : 10, step : 1,
      slide: (event, ui) => @availabilityQuantityChanged(ui.value)
    )

  initializeGeolocateButton: ->
    @geolocateButton = @form.find(".geolocation")
    @geolocateButton.addClass("active").bind 'click', =>
      @geolocateMe()

    # Set it by default if available
    existing = @geolocateButton.attr("data-geo-val")
    @queryField.val(existing) if existing? && @queryField.val() == ''

  geolocateMe: ->
    @determineUserLocation()
    @queryField.val(@geolocateButton.attr("data-geo-val")).change().focus()

  determineUserLocation: ->
    return unless Modernizr.geolocation
    navigator.geolocation.getCurrentPosition (position) =>
      geocoder = new google.maps.Geocoder()
      geocoder.geocode { address: position.coords.latitude + "," + position.coords.longitude }, (results, status) =>
        components = results[0].address_components
        city       = null
        country    = null

        for component in components
           types   = component.types
           city    = component.long_name if types.indexOf('locality') >= 0 && types.indexOf('political') >= 0
           country = component.long_name if types.indexOf('country') >= 0 && types.indexOf('political') >= 0

        if city
          currentLocation = "#{city}, #{country}"
          @queryField.val(currentLocation).change()

class DNM.HomeSearch extends DNM.SearchForm


class DNM.SearchResultsPage extends DNM.SearchForm
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
      popupContent = $('.map-details', listing.element).html()
      google.maps.event.addListener @map.markers[listing.id], 'click', =>
        @map.info_window.setContent(popupContent)
        @map.info_window.open(@map.map, @map.markers[listing.id])

  triggerSearch: ->
    @startLoading()
    data = @form.serialize()
    $.ajax(
      url     : @form.attr("src")
      type    : 'GET',
      data    : data,
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
