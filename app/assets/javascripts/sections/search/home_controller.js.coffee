# Controller for search form on the homepage
class Search.HomeController extends Search.Controller
  constructor: (form, @container) ->
    super(form)
    @queryField.keypress (e) =>
      if e.which == 13
        # if user pressed enter, we will prevent submitting the form and do it manually, when we are ready [ i.e. after geocoding query ]
        @submit_form = true
        false

