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
    @initializeAmenitiesField()
    @initializeAssociationsField()
    @initializeDateRangeField()

  availabilityQuantityChanged: (value) ->
    @availabilityQuantityField = @form.find('.availability-quantity input').val(value)
    @form.find('.availability-quantity .value').text(value)
    @fieldChanged('availability-quantity', value)

  priceRangeChanged: (values) ->
    @form.find(".price-range input[name*=min]").val(values[0])
    @form.find(".price-range input[name*=max]").val(values[1])
    @form.find(".price-range .value").text("$#{values[0]} - $#{values[1]}/day")
    @fieldChanged('priceRange', values)

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
    existing = @geolocateButton.attr("data-geo-val")
    @queryField.val(existing) if existing?

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
          @queryField.val(currentLocation).change()

class DNM.HomeSearch extends DNM.SearchForm


class DNM.SearchResultsPage extends DNM.SearchForm
  constructor: (form, @container) ->
    super(form)
    @resultsContainer = @container.find('.results')
    @loadingContainer = @container.find('.loading')

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


