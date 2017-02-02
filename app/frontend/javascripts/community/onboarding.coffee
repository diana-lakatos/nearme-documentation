AddressController = require('./address_controller')

module.exports = class Onboarding
  constructor: ->

  # toggles is-active class on parent container on onboarding: follow page
  @followCheckboxes: ->
    $('.card-b input').on('change.card', (event) ->
      $(this).closest('.card-b').toggleClass('is-active', $(this).prop('checked'))
    )

  # geolocation when entering user location
  @locationSelector: ->
    return unless window.google and window.google.maps
    new AddressController($('.form-a .fields.location'))

  @initialize: ->
    @followCheckboxes()
    @locationSelector()
