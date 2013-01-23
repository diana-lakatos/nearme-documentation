# Base search controller
# Extended by Search.HomeController and Search.SearchController
class Search.Controller
  constructor: (@form) ->
    @initializeFields()
    @initializeGeolocateButton()
    @initializeAutocomplete()
    @initializeGeocoder()

  initializeAutocomplete: ->
    @autocomplete = new google.maps.places.Autocomplete(@queryField[0], {})

  initializeGeocoder: ->
    @geocoder = new Search.Geocoder()

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
    @form.find(".availability-quantity .slider").slider(
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
      deferred = @geocoder.reverseGeocodeLatLng(position.coords.latitude, position.coords.longitude)
      deferred.done (resultset) =>
        cityAddress = resultset.getBestResult().cityAddress()
        @queryField.val(cityAddress).change() if cityAddress