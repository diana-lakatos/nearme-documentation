class @Support.TicketMessageController

  constructor: (@container) ->
    @form = @container.find('form[data-attachment-form]')
    @uploadAttachment = @container.find('a[data-upload]')
    @fileUpload = @form.find('input[data-file]')
    @attachmentList = @container.find('[data-attachment-list]')
    @template = @attachmentList.find('[data-template]')
    @bindEvents()

  bindEvents: ->

    @attachmentList.find('a[data-delete]').on 'click', (e) =>
      e.preventDefault()
      a = $(e.target).closest('a')

      if confirm(a.data('delete'))
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
        Modal.showContent(@uploadAttachment.data('uploading'))
        @data = new FormData()
        @data.append('support_ticket_message_attachment[file]', file)
        @data.append('form_name', @uploadAttachment.data('form-name'))
        $.ajax
          type: 'POST'
          url: @form.attr("action")
          data: @data
          cache: false
          processData: false
          contentType: false
          success: (data) =>
            @attachmentList.append(data.attachment_content)
            Modal.showContent(data.modal_content)
          error: (xhr) =>
            Modal.showContent(@uploadAttachment.data('error'))

