class @Users.InstanceAdmins.Controller

  constructor: (@container, @options = {}) ->
    @roleSelects = @container.find('select[data-role-select]')
    @bindEvents()

  bindEvents: ->

    @roleSelects.on 'change',  (event) =>
      $.ajax(
        type: 'PUT',
        url: '/instance_admin/users/instance_admins/' + $(event.target).data('instance-admin-id'),
        data: { instance_admin_role_id: $(event.target).val() }
      )
