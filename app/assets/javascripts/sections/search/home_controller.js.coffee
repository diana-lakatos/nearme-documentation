# Controller for search form on the homepage
class Search.HomeController extends Search.Controller
  constructor: (form, @container) ->
    @form = form
    @initializeSearchForm()
    @initializeCategorySelect()

    super(@form)
    if @queryField.val() == '' && @autocompleteEnabled()
      _.defer(=>@geolocateMe())

  initializeSearchForm: ->

    # when submitting the form without clicking on autocomplete, we need to check if the field's value has been changed to update lat/lon and address components.
    # otherwise, no matter what we type in, we will always get results for geolocated address
    @form.submit (e) =>
      e.preventDefault()
      if(@queryField.val() != @cached_geolocate_me_city_address)
        if(@queryField.val())
          @geocoder = new Search.Geocoder()
          deferred = @geocoder.geocodeAddress(@queryField.val())
          deferred.always (resultset) =>
            if(resultset?)
              @setGeolocatedQuery(@queryField.val(), resultset.getBestResult())
            $(e.target).unbind('submit').submit()
        else
          @setGeolocatedQuery(@cached_geolocate_me_city_address, @cached_geolocate_me_result_set)
          $(e.target).unbind('submit').submit()
      else
        $(e.target).unbind('submit').submit()

  initializeCategorySelect: ->
    @product_category_select = @form.find(".product_category_select")
    @service_category_select = @form.find(".service_category_select")
    @transactable_select = @form.find(".transactable_select")

    @transactable_select.on 'change', (event) =>
      @onTransactableSelectChange()

    @onTransactableSelectChange()

  onTransactableSelectChange: ->
    if (@transactable_select.find('[value="' + @transactable_select.val() + '"]').attr('data-buyable') == 'true')
      @form.find(".product_category_select").show()
      @form.find(".product_category_select").prop('disabled', false);
      @form.find(".service_category_select").hide()
      @form.find(".service_category_select").prop('disabled', true);
    else
      @form.find(".product_category_select").hide()
      @form.find(".product_category_select").prop('disabled', true);
      @form.find(".service_category_select").show()
      @form.find(".service_category_select").prop('disabled', false);




