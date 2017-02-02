Modal = require('../../components/modal')

module.exports = class SupportTicketMessageController

  constructor: (@container) ->
    @form = @container.find('form[data-attachment-form]')
    @uploadAttachment = @container.find('a[data-upload]')
    @fileUpload = @form.find('input[data-file]')
    @attachmentList = @container.find('[data-attachment-list]')
    @template = @attachmentList.find('[data-template]')
    @modal = $("#bootstrap-modal")
    @bindEvents()

  bindEvents: ->

    @attachmentList.on 'click', (e) =>
      e.preventDefault()
      a = $(e.target).closest('a')

      if a.data('delete') && confirm(a.data('delete'))
        $.ajax
          type: 'POST'
          url: a.attr('href')
          data: { "_method":"delete" }
          success: (data) ->
            a.closest('.attachment').fadeOut 'slow', ->
              $(this).remove()
          error: (xhr) =>
            Modal.showContent(@uploadAttachment.data('destroy-error'))

    @uploadAttachment.on 'click', (e) =>
      e.preventDefault()
      @fileUpload.click()

    @form.find('input:file').on 'change', (event) =>
      $.each $(event.target)[0].files, (key, file) =>

        if @modal.length > 0
          @modal.modal("show")
        else
          Modal.showContent(@uploadAttachment.data('uploading'))

        @data = new FormData()
        @data.append('support_ticket_message_attachment[file]', file)
        @data.append('form_name', @uploadAttachment.data('form-name'))
        $.ajax
          type: 'POST'
          url: @form.attr("action")
          data: @data
          dataType: 'JSON'
          cache: false
          processData: false
          contentType: false
          success: (data, a, b) =>
            @attachmentList.append(data.attachment_content)
            if @modal.length > 0
              @modal.find(".modal-body").html(data.modal_content)
            else
              Modal.showContent(data.modal_content)
          error: (xhr) =>
            try
              validJson = JSON.parse(xhr.responseText)
            catch
              validJson = false

            if validJson && validJson.error_message
              error_message = validJson.error_message
            else
              error_message = @uploadAttachment.data('error')

            if @modal.length > 0
              @modal.find(".modal-body").html(error_message)
            else
              Modal.showContent(error_message)

