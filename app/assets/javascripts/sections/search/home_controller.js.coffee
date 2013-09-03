# Controller for search form on the homepage
class Search.HomeController extends Search.Controller
  constructor: (form, @container) ->
    super(form)
    @queryField.keypress (e) =>
      if e.which == 13
        # if user pressed enter, we will prevent submitting the form and do it manually, when we are ready [ i.e. after geocoding query ]
        @submit_form = true
        false

    # when submiting the form without clicking on autocomplete, we need to check if the field's value has been changed to update lat/lon and address components. 
    # otherwise, no matter what we type in, we will always get results for geolocated address
    form.submit (e) =>
      e.preventDefault()
      if(@queryField.val() != @cached_geolocate_me_city_address)
        if(@queryField.val())
          @geocoder = new Search.Geocoder()
          deferred = @geocoder.geocodeAddress(@queryField.val())
          deferred.done (resultset) =>
            @setGeolocatedQuery(@queryField.val(), resultset.getBestResult())
            $(e.target).unbind('submit').submit()
        else
          @setGeolocatedQuery(@cached_geolocate_me_city_address, @cached_geolocate_me_result_set)
          $(e.target).unbind('submit').submit()
      else
        $(e.target).unbind('submit').submit()



