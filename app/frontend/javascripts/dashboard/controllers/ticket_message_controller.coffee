module.exports = class TicketMessageController

  constructor: (el) ->
    @container = $(el)
    @form = @container.find('[data-rfq-attachment-form]')
    @input = @form.find('input[data-file]')
    @attachmentList = @container.find('[data-attachment-list]')
    @label = @container.find('[data-attachment-label]')
    @labelTextHolder = @label.find('span')
    @labelText =
      default: @labelTextHolder.text()
      uploading: @label.data('attachment-label')

    @bindEvents()

  initializeLabel: ->

  bindEvents: ->
    @attachmentList.on 'click', 'a[data-delete]', @deleteAttachment
    @input.on 'change', @submitForm
    @attachmentList.on 'change', 'select', @updateTag

  deleteAttachment: (e) =>
    e.preventDefault()
    a = $(e.target).closest('a')

    return unless confirm(a.data('delete'))

    $.ajax
      type: 'POST'
      url: a.attr('href')
      data: { "_method":"delete" }
      success: (data) ->
        a.closest('.attachment').remove()
      error: (xhr) =>
        alert @input.data('destroy-error')

  updateTag: (e) ->
    data =
      "_method": "put",
      "support_ticket_message_attachment[tag]": $(e.target).val()

    $.ajax
      type: 'POST'
      url: $(e.target).closest('[data-update-url]').data('update-url')
      data: data
      error: (xhr) ->
        alert 'Unable to change attachment tag'

  submitForm: =>
    $.each @input.get(0).files, (key, file) =>
      data = new FormData()
      data.append('support_ticket_message_attachment[file]', file)
      data.append('form_name', @input.data('form-name'))

      @label.addClass('uploading')
      @labelTextHolder.text(@labelText.uploading)

      $.ajax
        type: 'POST'
        url: @form.attr("action")
        data: data
        dataType: 'JSON'
        cache: false
        processData: false
        contentType: false
        success: (data) =>
          @label.removeClass('uploading')
          @labelTextHolder.text(@labelText.default)

          new_item = $(data.attachment_content)
          @attachmentList.append(data.attachment_content)
          $('html').trigger('selects.init.forms', [new_item])

        error: (xhr) =>
          alert @input.data('error')
