require 'jquery-ui/ui/widgets/sortable'
require 'swipebox/src/js/jquery.swipebox'
require 'imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.iframe-transport.js'
require 'imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.fileupload.js'

require '../../vendor/jquery-dragster'

module.exports = class ImageInput

  constructor: (input) ->
    console.log("DNM :: ImageInput :: Initializing")

    @fileInput = $(input)
    @container = @fileInput.closest('.form-group')
    @form = @fileInput.closest('form')
    @fieldWrapper = @fileInput.closest('.input-preview')

    @isMultiple = !!@fileInput.attr('multiple')
    @isJsUpload = !!@fileInput.data('upload-url')
    @hasCaptions = !!@fileInput.data('has-captions')
    @captionPlaceholder = @fileInput.data('caption-placeholder')

    @objectName = @fileInput.data('object-name')
    @modelName = @fileInput.data('model-name')
    @label = @container.find('label')

    @dropzoneLabel = @fileInput.data('dropzone-label')
    @updateOnSaveLabel = @fileInput.data('upload-on-save-label')

    @collection = @container.find('[data-image-collection]')
    @isSortable = !!@collection.attr('data-sortable')

    @allowedFileTypes = ['jpg','jpeg','gif','png']


    @processing = 0

    @initializePreview()

    @initializeSortable() if @isSortable

    if @isJsUpload
      @initializeFileUpload()
      @initializeDraggable()
      @initializeProgressbar()

    @bindEvents()

  bindEvents: ->
    @listenToDeletePhoto()
    @listenToEditPhoto()
    @listenToDragFile()
    @listenToPreviewEvents()
    @preventEarlySubmission()

    @listenToInputChange() if !@isJsUpload and Modernizr.filereader

  initializePreview: ->
    @preview = $('<div class="form-images__preview"><figure><img src=""></figure><span class="form-images__preview__close">Close preview</span></div>')
    @preview.appendTo('body')

  showPreview: (url) ->
    @preview.find('figure').html("<img src='#{url}'>")
    @preview.addClass('preview--active')

    # close on ESC
    $('body').on 'keydown.preview', (e) =>
      @hidePreview() if e.which is 27

  hidePreview: ->
    @preview.removeClass('preview--active')
    # remove close on ESC event
    $('body').off 'keydown.preview'

  listenToPreviewEvents: ->
    @preview.on 'click', =>
      @hidePreview()

    @container.on 'click', '.action--preview', (e) =>
      e.preventDefault()
      e.stopPropagation()
      url = $(e.target).closest('a').attr('href')
      @showPreview(url)

  validateFileType: (file) ->
    types = $.map @allowedFileTypes, (item) ->
      "image/#{item}"

    return $.inArray(file.type, types) > -1


  # It will show the dropzone on file dragging to browser window
  listenToDragFile: ->
    $(window).dragster
      enter: =>
        @fieldWrapper.addClass('drag-active')
      leave: =>
        @fieldWrapper.removeClass('drag-active')
      drop: =>
        @fieldWrapper.removeClass('drag-active')

  listenToDataUrlPreview: ->
    @container.on 'click', 'action--dataurl-preview', (e) ->
      src = $(e.target).closest('a').find('img').attr('src')
      showPreview()


  listenToInputChange: ->
    reader = new FileReader()

    reader.onloadend = =>
      @updatePreview({ dataUrl: reader.result })

    @fileInput.on 'change', ->
      if @isMultiple
        throw new Error('Support for multiple files without XHR is not implemented')
      else
        file = this.files[0]
        reader.readAsDataURL(file) if file

  initializeDraggable: ->
    @fieldWrapper.addClass('draggable-enabled')

    @dropzone = $("<div class='drop-zone'><div class='text'>#{@dropzoneLabel}</div></div>")
    @dropzone.prependTo(@fieldWrapper)


  initializeProgressbar: ->
    @fieldWrapper.prepend("<div class='file-progress'><div class='bar'></div><div class='text'></div></div>")
    @uploadLabelContainer = @container.find('.file-progress  .text')

  initializeFileUpload: ->

    @fileInput.fileupload
      url: @fileInput.data('upload-url')
      paramName: @fileInput.data('upload-name')
      dataType: 'json'
      dropZone: @dropZone
      formData: (form) ->
        params = form.clone()
        params.find("input[name=_method]").remove()
        params.serializeArray()

      start: =>
        @fieldWrapper.addClass('progress--active')

      stop: =>
        @fieldWrapper.removeClass('progress--active')

      add: (e, data) =>
        @updateProcessing(1)
        file = data.files[0]
        if @validateFileType(file)
          @updateLabel()
          data.submit()
        else
          alert("#{file.name} seems to not be an image - please select gif, jpg, jpeg or png file")

      done: (e, data) =>
        if @isMultiple
          @collection.append @createCollectionItem(data.result)
          @reorderSortableList()
        else
          @updatePreview(data.result)

        @rebindEvents()

      fail: (e, data) ->
        window.alert('Unable to process this request, please try again.')
        window.Raygun.send(data.errorThrown, data.textStatus) if window.Raygun

      always: (e, data) =>
        @updateProcessing(-1)
        @updateLabel()

  updatePreview: (data) ->
    preview = @fieldWrapper.find('.preview').empty()

    if preview.length is 0
      preview = $('<div class="preview"/>').prependTo(@fieldWrapper)

    preview.html('<figure/><div class="form-images__options"/>')

    options = preview.find('.form-images__options')

    if data.sizes?
      preview.find('figure').append("<a href=\"#{data.sizes.full.url}\" class='action--preview'><img src=\"#{data.sizes.space_listing.url}\"></a>")

    if data.url?
      preview.find('figure').append("<a href=\"#{data.url}\" class='action--preview'><img src=\"#{data.url}\"></a>")

    if data.dataUrl?
      a = $('<a class="action--preview"/>')
      a.attr('href', data.dataUrl)
      a.append('<img src="' + data.dataUrl + '">')
      preview.find('figure').append(a)

    if data.resize_url?
      options.append("<button type='button' class='action--edit' data-edit data-url='#{data.resize_url}'>Crop & Resize</button>")

    if data.destroy_url?
      options.append("<button type='button' class='action--delete' data-delete data-url='#{data.destroy_url}' data-label-confirm='Are you sure you want to delete this image?'>Remove</button>")

    preview.append("<small>#{@updateOnSaveLabel}</small>") unless @isJsUpload


  initializeSortable: ->
    @collection.sortable
      stop: =>
        @reorderSortableList()
      placeholder: 'photo-placeholder'
      handle: '.sort-handle'
      cancel: 'input'
      scroll: false

    @reorderSortableList()

  rebindEvents: ->
    @collection.find('.action--preview').swipebox()

  createCollectionItem: (data) ->
    container = $('<li data-photo-item/>')
    container.append("<a href=\"#{data.sizes.full.url}\" class='action--preview'><img src=\"#{data.sizes.space_listing.url}\"></a>")
    options = $('<div class="form-images__options">').appendTo(container)
    if data.resize_url
      options.append("<button type='button' class='action--edit' data-edit data-url='#{data.resize_url}'>Crop & Resize</button>")

    if data.destroy_url
      options.append("<button type='button' class='action--delete' data-delete data-url='#{data.destroy_url}' data-label-confirm='Are you sure you want to delete this image?'>Remove</button>")

    if @isSortable
      container.append('<span class="sort-handle"/>')
      container.append("<input type='hidden' name='#{@objectName}[#{@modelName}_ids][]' value='#{data.id}'>")
      container.append("<input type='hidden' name='#{@objectName}[#{@modelName}s_attributes][#{data.id}][id]' value='#{data.id}'>")
      container.append("<input type='hidden' name='#{@objectName}[#{@modelName}s_attributes][#{data.id}][position]' value='' class='photo-position-input'>")

    if @hasCaptions
      container.append("<span class='caption'><input type='text' name='#{@objectName}[#{@modelName}s_attributes][#{data.id}][caption]' value='' placeholder='#{@captionPlaceholder}'></span>")

    container

  listenToDeletePhoto: ->
    @container.on 'click', '[data-delete]', (e) =>
      e.preventDefault()

      @updateProcessing(1)
      trigger = $(e.target).closest('[data-delete]')
      url = trigger.data("url")
      labelConfirm = trigger.data('label-confirm')
      return unless confirm(labelConfirm)

      photo = trigger.closest("[data-photo-item], .preview").addClass('deleting')

      $.post url, { _method: 'delete' }, =>
        photo.remove()
        @updateProcessing(-1)
        @reorderSortableList()

  listenToEditPhoto: ->
    @container.on 'click', '[data-edit]', (e) ->
      e.preventDefault()
      trigger = $(e.target).closest('[data-edit]')
      url = trigger.data("url")
      $(document).trigger('load:dialog.nearme', [{ url: url }])

  updateLabel: ->
    switch @processing
      when 0 then text = 'All files uploaded'
      when 1 then text = 'Uploading photo...'
      else text = "Uploading #{@processing} photos..."

    @uploadLabelContainer.html text

  updateProcessing: (change) =>
    @processing = @processing + change
    @form.data('processing', @processing > 0)

  preventEarlySubmission: ->
    @form.on 'submit', (e) =>
      if @form.data('processing')
        alert 'Please wait until all files are uploaded before submitting.'
        e.preventDefault()
        e.stopPropagation()

  reorderSortableList: ->
    return unless @isSortable

    @collection.sortable('refresh')
    @collection.find('li').each (index, el) ->
      $(el).find('.photo-position-input').val(index)
