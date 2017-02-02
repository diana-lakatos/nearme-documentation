Modal = require('../../components/modal')

module.exports = class SupportAttachmentForm

  constructor: (@form) ->
    @bindEvents()
    @attachmentList = $('[data-attachment-list]')

  bindEvents: ->
    @form.submit =>
      $.ajax
        type: 'POST'
        url: @form.attr("action")
        data: @form.serialize()
        success: (data) ->
          $("#support_ticket_message_attachment_#{data.attachment_id}").replaceWith(data.attachment_content)
          Modal.close()
        error: (xhr) ->
          Modal.showContent(xhr.responseText)
      false

