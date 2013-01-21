class @EditUserForm

  constructor: () ->
    @bindEvents()

  bindEvents: ->
    $('.services_list').on 'click', '.provider-not-disconnectable', (event) =>
        $('#user_password').effect("highlight", {}, 3000).focus()
        $('#fill-password-request').removeClass('hidden')
        false
        
