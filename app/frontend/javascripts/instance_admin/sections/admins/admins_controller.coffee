module.exports = class InstanceAdminAdminsController

  constructor: (@container, @options = {}) ->
    @roleSelects = @container.find('select[data-role-select]')
    @bindEvents()

  bindEvents: ->
    @roleSelects.on 'change',  (event) =>
      @loading_gif = $(event.target).siblings('[data-loading]').eq(0)
      @loading_gif.show()
      $.ajax(
        type: 'PUT',
        url: '/instance_admin/manage/admins/instance_admins/' + $(event.target).data('instance-admin-id'),
        data: { instance_admin_role_id: $(event.target).val() },
        success: =>
          @loading_gif.hide()
      )
