# New search functionality implementation.
#
#
class DNM.SearchForm
  constructor: (@form) ->
    @initializeFields()
    @initializeGeolocateButton()

  # Initialize all filters for the search form
  initializeFields: ->
    @initializePriceRangeFilter()
    @initializeAvailabilityQuantityFilter()
    @initializeQueryField()

  availabilityQuantityChanged: (value) ->
    @form.find('.availability-quantity input').val(value)
    @form.find('.availability-quantity .value').text(value)

    @fieldChanged('availability-quantity', value)

  priceRangeChanged: (values) ->
    @form.find(".price-range input[name*=min]").val(values[0])
    @form.find(".price-range input[name*=max]").val(values[1])
    @form.find(".price-range .value").text("$#{values[0]} - $#{values[1]}/day")

    @fieldChanged('priceRange', values)

  fieldChanged: (filter, value) ->
    # Override to trigger automatic updating etc.

  initializeQueryField: ->
    @queryField = @form.find('input.query')
    @queryField.bind 'change', =>
      @fieldChanged('query', @queryField.val())

    # TODO: Trigger fieldChanged on keypress after a few seconds timeout?

  initializePriceRangeFilter: ->
    @form.find('.price-range .slider').slider(
      range: true, values: [0, 100], min  : 0, max  : 300, step : 25,
      slide: (event, ui) => @priceRangeChanged(ui.values)
    )

  initializeAvailabilityQuantityFilter: ->
    @form.find(".availability-quantity .slider").slider(
      value: 1, min  : 1, max  : 10, step : 1,
      slide: (event, ui) => @availabilityQuantityChanged(ui.value)
    )

  initializeGeolocateButton: ->
    @geolocateButton = @form.find("input.geolocation")
    @geolocateButton.addClass("active").bind 'click', =>
      @queryField.val(@geolocateButton.attr("data-geo-val")).change().focus()

    if currentLocation = $.cookie("currentLocation")
      @geolocateButton.attr("data-geo-val", currentLocation)
    else
      @determineUserLocation()

    # Set it by default if available
    @geolocateButton.trigger('click') if @geolocateButton.attr("data-geo-val")?

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
          $.cookie("currentLocation", currentLocation)
          setSearchFormToLocation(searchForm, currentLocation)

class DNM.HomeSearch extends DNM.SearchForm


class DNM.SearchResultsPage extends DNM.SearchForm
  constructor: (form, container) ->
    super(form)
    @resultsContainer = container

  bindEvents: ->
    @form.bind 'submit', (event) =>
      event.preventDefault()
      @triggerSearch()

  filterChanged: (filter, value) ->
    # Trigger automatic updating of search results


