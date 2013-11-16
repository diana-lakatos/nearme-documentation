class @Users.InstanceAdminRoles.Controller

  constructor: (@container, @options = {}) ->
    @permissionCheckboxes = @container.find('input[data-permission-checkbox]')
    @bindEvents()

  bindEvents: ->

    @permissionCheckboxes.on 'change',  (event) =>
      str = '{"instance_admin_role": {"' + $(event.target).data('permission-checkbox') + '": "' + $(event.target).is(':checked') + '"}}'
      @loading_gif = $(event.target).siblings('[data-loading]').eq(0)
      @loading_gif.show()
      $.ajax(
        type: 'PUT',
        url: '/instance_admin/users/instance_admin_roles/' + $(event.target).data('role-id'),
        data: JSON.parse(str),
        success: =>
          @loading_gif.hide()
      )


