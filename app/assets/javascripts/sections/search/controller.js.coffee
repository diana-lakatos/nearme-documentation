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
    google.maps.event.addListener @autocomplete, 'place_changed', =>
      place = Search.Geocoder.wrapResult @autocomplete.getPlace()
      place = null unless place.isValid()

      @setGeolocatedQuery(@queryField.val(), place)

  initializeGeocoder: ->
    @geocoder = new Search.Geocoder()

  # Initialize all filters for the search form
  initializeFields: ->
    @priceRange = new PriceRange(@form.find('.price-range'), 300, @)
    @initializeAvailabilityQuantityFilter()
    @initializeQueryField()
    @initializeDateRangeField()

  availabilityQuantityChanged: (value) ->
    @availabilityQuantityField = @form.find('.availability-quantity input').val(value)
    @form.find('.availability-quantity .value').text(value)
    @fieldChanged('availability-quantity', value)

  dateRangeFieldChanged: (values) ->
    @fieldChanged('dateRange', values)

  fieldChanged: (filter, value) ->
    # Override to trigger automatic updating etc.

  initializeQueryField: ->
    @queryField = @form.find('input.query')
    if @queryField.val() == ''
      _.defer(=>@geolocateMe())

    @queryField.bind 'change', =>
      @fieldChanged('query', @queryField.val())

    # TODO: Trigger fieldChanged on keypress after a few seconds timeout?

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

  geolocateMe: ->
    @determineUserLocation()

  determineUserLocation: ->
    return unless Modernizr.geolocation
    navigator.geolocation.getCurrentPosition (position) =>
      deferred = @geocoder.reverseGeocodeLatLng(position.coords.latitude, position.coords.longitude)
      deferred.done (resultset) =>
        cityAddress = resultset.getBestResult().cityAddress()

        existingVal = @queryField.val()
        if cityAddress != existingVal
          @queryField.val(cityAddress)
          @fieldChanged('query', @queryField.val())

  # Is the given query currently geolocated by the search
  isQueryGeolocated: (query) ->
    # Note that we don't check the presence of the gelocation result. This is because the result can be null,
    # which means geolocation was attempted but failed, so we don't try again.
    @currentGeolocationResultQuery == query

  # Set the active geolocated query. Triggers updating of the form params.
  setGeolocatedQuery: (query, result) ->
    @currentGeolocationResultQuery = query
    @currentGeolocationResult = result
    @assignFormParams @searchParamsFromGeolocationResult(result)

  # Returns special search params based on a geolocation result (Search.Geolocator.Result), or no result.
  searchParamsFromGeolocationResult: (result) ->
    params = { lat: null, lng: null, nx: null, ny: null, sx: null, sy: null }

    if result
      boundingBox = result.boundingBox()
      params['lat'] = result.lat()
      params['lng'] = result.lng()
      params['nx']  = boundingBox[0]
      params['ny']  = boundingBox[1]
      params['sx']  = boundingBox[2]
      params['sy']  = boundingBox[3]

    params

  assignFormParams: (paramsHash) ->
    # Write params to search form
    for field, value of paramsHash
      @form.find("input[name*=#{field}]").val(value)

  # Geocde the search query and assign it as the geocoded result
  geocodeSearchQuery: (callback) ->
    query = @queryField.val()

    # If the query has already been geolocated we can just search immediately
    if @isQueryGeolocated(query)
      return callback()

    # Otherwise we need to geolocate the query and assign it before searching
    deferred = @geocoder.geocodeAddress(query)
    deferred.always (results) =>
      result = results.getBestResult() if results

      @setGeolocatedQuery(query, result)
      callback()



