module.exports = class ApprovalRequestAttachmentsController

  constructor: (container) ->
    @container = $(container)
    @bindEvents()

  bindEvents: =>
    @container.on 'ajax:success', 'a[data-delete-attachment]', (event) ->
      $(event.target).parent().html('')
