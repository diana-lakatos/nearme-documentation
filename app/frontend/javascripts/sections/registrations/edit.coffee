DashboardAddressController = require('../dashboard/address_controller')

module.exports = class EditUserForm

  constructor: (el) ->
    @container = $(el)
    @bindEvents()
    new DashboardAddressController($('#edit_user'))

  bindEvents: ->
    $('.services_list').on 'click', '.provider-not-disconnectable', (event) ->
      $('#user_password').effect("highlight", {}, 3000).focus()
      $('#fill-password-request').removeClass('hidden')
      false

    @container.find("input").on "change paste keyup", ->

      profileLink = specialThings = $('a.profile-link')

      if profileLink.length > 0
        $('a.profile-link').attr('data-confirm', "You have unsaved changes in your profile. Do you want to leave this page and discard changes?")
