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
      @fieldChanged('query', @queryField.val())

  initializeGeocoder: ->
    @geocoder = new Search.Geocoder()

  # Initialize all filters for the search form
  initializeFields: ->
    @priceRange = new PriceRange(@form.find('.price-range'), 300, @)
    @initializeQueryField()
    @initializeDateRangeField()

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
      params['lat'] = @formatCoordinate(result.lat())
      params['lng'] = @formatCoordinate(result.lng())
      params['nx']  = @formatCoordinate(boundingBox[0])
      params['ny']  = @formatCoordinate(boundingBox[1])
      params['sx']  = @formatCoordinate(boundingBox[2])
      params['sy']  = @formatCoordinate(boundingBox[3])

    params

  formatCoordinate: (coord) ->
    coord.toFixed(5)

  assignFormParams: (paramsHash) ->
    # Write params to search form
    for field, value of paramsHash
      @form.find("input[name*=#{field}]").val(value)

  getSearchParams: ->
    params = {}
    params[param] = @form.find("input[name*=#{param}]").val() for param in ['lat', 'lng', 'nx', 'ny', 'sx', 'sy', 'q']
    params

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
