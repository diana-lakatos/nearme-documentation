DashboardAddressController = require('../dashboard/address_controller')

module.exports = class EditUserForm

  constructor: () ->
    @bindEvents()
    new DashboardAddressController($('#edit_user'))

  bindEvents: ->
    $('.services_list').on 'click', '.provider-not-disconnectable', (event) =>
        $('#user_password').effect("highlight", {}, 3000).focus()
        $('#fill-password-request').removeClass('hidden')
        false

