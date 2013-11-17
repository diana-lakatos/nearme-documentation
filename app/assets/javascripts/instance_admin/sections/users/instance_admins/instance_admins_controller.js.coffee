class @Users.InstanceAdmins.Controller

  constructor: (@container, @options = {}) ->
    @roleSelects = @container.find('select[data-role-select]')
    @bindEvents()
    @loading_gif = @roleSelects.siblings('[data-loading]').eq(0)

  bindEvents: ->

    @roleSelects.on 'change',  (event) =>
      @loading_gif.show()
      $.ajax(
        type: 'PUT',
        url: '/instance_admin/users/instance_admins/' + $(event.target).data('instance-admin-id'),
        data: { instance_admin_role_id: $(event.target).val() },
        success: =>
          @loading_gif.hide()

      )
