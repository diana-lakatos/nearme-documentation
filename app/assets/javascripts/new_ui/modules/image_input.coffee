class @DNM.ImageInput

  constructor : (input) ->
    @fileInput = $(input)
    @container = @fileInput.closest('.form-group')
    @isMultiple = !!@fileInput.attr('multiple')
    @isJsUpload = !!@fileInput.data('upload-url')
    @objectName = @fileInput.data('object-name')
    @modelName = @fileInput.data('model-name')
    @label = @container.find('label')
    @collection = @container.find('[data-image-collection]')
    @isSortable = !!@collection.attr('data-sortable')
    @preventEarlySubmission()
    @processing = 0

    @bindEvents()

    @initializeSortable() if @isSortable
    @initializeFileUpload() if @isJsUpload

    if sessioncamConfiguration?
      sessioncamConfiguration.customDataObjects.push( { key: "event", value: "first_listing_form_visit" } )

  bindEvents: ->
    @listenToDeletePhoto()
    @listenToFormSubmit()
    @listenToEditPhoto()

    @listenToInputChange() if !@isJsUpload


  listenToInputChange: ->
    @fileInput.on 'change', =>
      @updateLabel()

  initializeFileUpload: ->

    @fileInput.fileupload
      url: @fileInput.data('upload-url')
      paramName: @fileInput.data('upload-name')
      dataType: 'json'
      dropZone: @container
      formData: (form) ->
        params = form.clone()
        params.find("input[name=_method]").remove()
        params.serializeArray()
      add: (e, data) =>
        @processing += 1
        types = /(\.|\/)(gif|jpe?g|png)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          @updateLabel()
          data.submit()
        else
          if @wrong_file_message && @wrong_file_message != ''
            alert("#{file.name} " + @wrong_file_message)
          else
            alert("#{file.name} seems to not be an image - please select gif, jpg, jpeg or png file")
      done: (e, data) =>
        @processing -= 1
        @updateLabel()
        @collection.append @createItem(data.result)
        @rebindEvents()

        @reorderSortableList()

  initializeSortable: ->
    @collection.sortable
      stop: =>
        @reorderSortableList()
      placeholder: 'photo-placeholder'
      handle: '.sort-handle'
      cancel: 'input'

    @reorderSortableList()

  rebindEvents: ->
    @collection.find('.action--preview').swipebox()

  createItem: (data)->
    container = $('<li data-photo-item/>')
    container.append("<a href='#{data.sizes.full.url}' class='action--preview' rel='preview-#{data.id}'><img src='#{data.sizes.space_listing.url}'></a>")
    options = $('<div class="options">').appendTo(container)
    if data.resize_url
      options.append("<button type='button' class='action--edit' data-edit data-url='#{data.resize_url}'>Crop & Resize</button>")

    if data.destroy_url
      options.append("<button type='button' class='action--delete' data-delete data-url='#{data.destroy_url}' data-label-confirm='Are you sure you want to delete this image?'>Remove</button>")

    if @isSortable
      container.append('<span class="sort-handle"/>')
      container.append("<input type='hidden' name='#{@objectName}[#{@modelName}_ids][]' value='#{data.id}'>")
      container.append("<input type='hidden' name='#{@objectName}[#{@modelName}s_attributes][#{data.id}][id]' value='#{data.id}'>")
      container.append("<input type='hidden' name='#{@objectName}[#{@modelName}s_attributes][#{data.id}][position]' value='' class='photo-position-input'>")

    container

  listenToDeletePhoto: ->
    @collection.on 'click', '[data-delete]', (e) =>
      e.preventDefault()

      @processingPhotos += 1
      trigger = $(e.target).closest('[data-delete]')
      url = trigger.data("url")
      labelConfirm = trigger.data('label-confirm')
      return unless confirm(labelConfirm)

      photo = trigger.closest("[data-photo-item]").addClass('deleting')

      $.post url, { _method: 'delete' }, =>
        photo.remove()
        @processingPhotos -= 1
        @reorderSortableList()

  listenToEditPhoto: ->
    @collection.on 'click', '[data-edit]', (e) =>
      e.preventDefault()
      trigger = $(e.target).closest('[data-edit]')
      url = trigger.data("url")
      $('html').trigger('load.dialog', [{ url: url }])

  listenToFormSubmit: ->
    @container.parents('form').on 'submit', (e)=>
      e.preventDefault() if @processingPhotos > 0


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
    defaultLabel = if @isMultiple then 'Add photo' else 'Upload photo'
    switch @processing
      when 0 then text = defaultLabel
      when 1 then text = 'Uploading photo...'
      else text = "Uploading #{@processing} photos..."

    @label.find('.add-label').html text
    @label.find('.drag-label').toggle(@processing is 0)
    @label.toggleClass('active-upload', @processing > 0)

  preventEarlySubmission: ->
    @container.parents('form').on 'submit', =>
      if @processing > 0
        alert 'Please wait until all files are uploaded before submitting.'
        false

  reorderSortableList: ->

    return unless @isSortable

    @collection.sortable('refresh')

    i = 0
    for index, el of @collection.sortable('toArray')
      if el != '' and $("##{el}.photo-item").length > 0
        $("##{el}").find('.photo-position-input').val(i)
        i++

$('input[data-image-input]').each ->
  new DNM.ImageInput(@)
