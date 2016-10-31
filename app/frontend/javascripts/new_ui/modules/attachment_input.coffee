require 'imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.iframe-transport.js'
require 'imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.fileupload.js'

module.exports = class AttachmentInput

  constructor : (input) ->
    @fileInput = $(input)
    @container = @fileInput.closest('.form-group')
    @isMultiple = !!@fileInput.attr('multiple')
    @isJsUpload = !!@fileInput.data('upload-url')
    @objectName = @fileInput.data('object-name')
    @label = @container.find('label')
    @collection = @container.find('[data-attachment-collection]')
    @preventEarlySubmission()
    @processing = 0
    @bindEvents()
    @initializeFileUpload()

  bindEvents: ->
    @listenToDeleteFile()
    @listenToFormSubmit()
    @listenToParamsChange()

  listenToParamsChange: =>
    @collection.on 'change', 'select[data-attachment-property]', (e)=>
      @updateAttachmentProperty(e.target)

    @collection.on 'blur', 'input[data-attachment-property]', (e)=>
      @updateAttachmentProperty(e.target)

  updateAttachmentProperty: (control) ->

    control = $(control)
    key = control.data('attachment-property')
    value = control.val()
    url = control.closest('[data-attachment]').data('update-url')

    # TODO - this should be generic rather than specific to seller attachments
    data = {'seller_attachment': { }}
    data.seller_attachment[key] = value

    $.ajax({
      url: url
      method: 'PUT',
      data: data
    })


  initializeFileUpload: ->

    @fileInput.fileupload
      url: @fileInput.data('upload-url')
      paramName: @fileInput.data('upload-name')
      dataType: 'html'
      dropZone: @container
      formData: (form) ->
        params = form.clone()
        params.find("input[name=_method]").remove()
        params.serializeArray()
      add: (e, data) =>
        if @isMultiple == false
          @collection.find('[data-attachment]').each (index, item)=>
            @removeItem(item)
        @processing += 1
        @updateLabel()
        data.submit()
      done: (e, data) =>
        @createItem(data.result)

      fail: (e, data) =>
        window.alert('Unable to process this request, please try again.')
        window.Raygun.send(data.errorThrown, data.textStatus) if window.Raygun

      always: (e, data)=>
        @processing -= 1
        @updateLabel()

  createItem: (html)->
    item = $(html)
    @collection.append(item)
    $('html').trigger('selects.init.forms', [item])

  removeItem: (item)->
    item = $(item)
    trigger = item.find('[data-delete]')
    url = trigger.data('url')
    item.addClass('deleting')

    @processingFiles += 1

    $.ajax
      url: url,
      method: 'post'
      data: { _method: 'delete' },
      success: =>
        item.remove()
        @processingFiles -= 1

  listenToDeleteFile: ->
    @collection.on 'click', '[data-delete]', (e) =>
      e.preventDefault()
      trigger = $(e.target).closest('[data-delete]')
      labelConfirm = trigger.data('label-confirm')
      return unless confirm(labelConfirm)

      @removeItem(trigger.closest('[data-attachment]'));

  listenToFormSubmit: ->
    @container.parents('form').on 'submit', (e)=>
      e.preventDefault() if @processingFiles > 0

  updateLabel: ->
    if @isJsUpload then @updateLabelJS() else @updateLabelStatic()

  updateLabelStatic: ->
    if @fileInput.get(0).files
      output = []
      _.each @fileInput.get(0).files, (item)->
        output.push(item.name)

      output = output.join(', ')
    else
      matches = @fileInput.val().match /\\([^\\]+)$/i
      output = matches[1]

    @label.find('.add-label').html output

  updateLabelJS: ->
    defaultLabel = if @isMultiple then 'Add file(s)...' else 'Select file...'
    switch @processing
      when 0 then text = defaultLabel
      when 1 then text = 'Uploading file...'
      else text = "Uploading #{@processing} files..."

    @label.find('.add-label').html text
    @label.toggleClass('active-upload', @processing > 0)

  preventEarlySubmission: ->
    @container.parents('form').on 'submit', =>
      if @processing > 0
        alert 'Please wait until all files are uploaded before submitting.'
        false
