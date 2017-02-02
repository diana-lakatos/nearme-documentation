SearchController = require('./controller')
SearchDatepickers = require('./datepickers')
SearchGeocoder = require('./geocoder')

# Controller for search form on the homepage
module.exports = class HomeController extends SearchController
  constructor: (form, @container) ->
    @form = $(form)
    @transactableTypePicker = @form.find("[data-transactable-type-picker]")
    @transactableTypeClass = @form.find("[name='transactable_type_class']")
    @transactableTypeId = @form.find("[name='transactable_type_id']")
    @queryField = @form.find('input[name="loc"]')
    @initializeSearchForm()
    @visibleFields = => @form.find('.transactable-type-search-box:visible')
    @visibleQueryField = => @visibleFields().find('input[name="loc"]:first')
    @keywordField = @form.find('input[name="query"]')
    @initializeGeolocateButton()

    @initializeGeocoder()

    $.each @form.find('.transactable-type-search-box'), (idx, container) =>
      new SearchDatepickers($(container))
      geo_input = $(container).find('input[name="loc"]')
      if geo_input.length > 0
        @initializeAutocomplete(geo_input)
        @initializeQueryField(geo_input)

    if @queryField.length > 0 && @form.find('.geolocation').data('enableGeoLocalization')
      _.defer(=>@geolocateMe())

  assignFormParams: (paramsHash) ->
    # Write params to search form
    for field, value of paramsHash
      if field != 'loc'
        @visibleFields().find("input[name='#{field}']").val(value)

  initializeQueryField: (queryField) ->
    queryField.bind 'focus', (event) ->
      input = $(event.target)
      if input.val() is input.data('placeholder')
        input.val('')
      true

    queryField.bind 'blur', (event) ->
      input = $(event.target)
      if input.val().length < 1 and input.data('placeholder')?
        _.defer(-> input.val(input.data('placeholder')))
      true

    # when submitting the form without clicking on autocomplete, we need to check if the field's value has been changed to update lat/lon and address components.
    # otherwise, no matter what we type in, we will always get results for geolocated address
    @form.submit (e) =>
      e.preventDefault()
      if(@visibleQueryField().length > 0 && @visibleQueryField().val() != @cached_geolocate_me_city_address)
        if(@visibleQueryField().val())
          @geocoder = new SearchGeocoder()
          deferred = @geocoder.geocodeAddress(@visibleQueryField().val())
          deferred.always (resultset) =>
            if(resultset?)
              @setGeolocatedQuery(@visibleQueryField().val(), resultset.getBestResult())
            $(e.target).unbind('submit').submit()
        else
          @setGeolocatedQuery(@cached_geolocate_me_city_address, @cached_geolocate_me_result_set)
          $(e.target).unbind('submit').submit()
      else
        $(e.target).unbind('submit').submit()

  initializeSearchForm: ->
    if @transactableTypePicker.length > 0
      if @transactableTypePicker.filter(':checked').length > 0
        @toggleTransactableTypes(@transactableTypePicker.filter(':checked').val())
      else
        @toggleTransactableTypes(@transactableTypePicker.val())
      @transactableTypePicker.bind "change", (event) =>
        @toggleTransactableTypes($(event.target).val())

  toggleTransactableTypes: (tt_id) ->
    id = tt_id.split('-')
    @transactableTypeClass.val(id[0])
    @transactableTypeId.val(id[1])
    inputs = @form.find("[data-transactable-type-id='#{tt_id}']")
    other_inputs = @form.find(".transactable-type-search-box")
    other_inputs.hide().find('input').prop('disabled', true)
    inputs.show().find('input').prop('disabled', false)
