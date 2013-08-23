class @PhotoUploader

  @uploaders = []

  @initialize: (scope = $('body')) ->
    $('.fileupload', scope).each (index, element) =>
      @uploaders.push new PhotoUploader($(element))

  # Update images to reload them when images were changed via e.g. ajax request.
  @updateImages: (ids = [])->
    for uploader in @uploaders
      for id in ids
        image = uploader.container.find("##{id}").find('img')
        continue unless image.length > 0
        image_src = image.attr('src')
        image.attr('src', image_src + '?' + (new Date()).getTime())

  constructor : (container) ->
    @container = container
    @sortable = container.find('#sortable-photos')
    @fileInput = container.find('.browse-file').eq(0)
    @photos = container.find('.photo-item a')
    @uploaded = container.find('.uploaded').eq(0)

    @init()
  
  init : ->
    @listenToDeletePhoto()
    @initializeFileUploader()
    @initializeSortable()
    __insp.push(['tagSession', "first_listing_form_visit"])

  listenToDeletePhoto: ->
    self = this
    @uploaded.on 'click', '.delete-photo',  ->
      url = $(this).attr("data-url")
      link = $(this)
      if confirm("Are you sure you want to delete this Photo?")
        $.post link.attr("data-url"), { _method: 'delete' }, =>
          link.closest(".photo-item").remove()
          if self.multiplePhoto()
            self.reorderSortableList()
      return false

  initializeFileUploader : =>
    @fileInput.fileupload {
        add: (e, data) =>
          # data.context will contain markup for image, that will be accessible in every other method like progress, done
          # to easily update the right container with appriopriate info [ i.e info that uploaded has been finished and inserting image preview]
          if @multiplePhoto()
            data.context = $('<div class="photo-item"></div>').appendTo(@sortable)
          else
            if @singlePhotoExists()
              data.context = @uploaded.find('.photo-item').eq(0)
            else
              data.context = $('<div class="photo-item"></div>').appendTo(@uploaded)
              
          if data.context.find('.progress').length == 0
            if $.browser.msie && parseInt($.browser.version) < 10
              data.context.append(@getLoadingElement('Uploading...'))
              data.context.find('.loading-icon').removeClass('loading-icon').addClass('animated-progress-bar')
            else
              data.context.append(@getLoadingElement("Uploading...<div class='progress'><div class='bar'></div></div>"))
              data.context.find('.loading-icon').css('visibility': 'hidden')
          data.submit()
        ,

        done:  (e, data) =>
          @addImg(data)
          @fileInput = @container.find('.browse-file').eq(0)
          @initializeFileUploader()
          if @multiplePhoto()
            @reorderSortableList()

        ,
        progress: (e, data) =>
          @progress(data)
    }

    @fileInput.on 'click', ->
      __insp.push(['tagSession', "photo_upload_clicked"])

  initializeSortable: ->
    @sortable.sortable
      stop: =>
        @reorderSortableList()
      placeholder: 'photo-placeholder'
      cancel: 'input'
    @sortable.find('*').not('input').disableSelection()

  progress: (data) =>
    progress = parseInt(data.loaded / data.total * 100, 10)
    @progressBar = data.context.find('.progress .bar').eq(0)
    @progressBar.css('width', progress + '%')
    if progress >= 99
      @progressBar.css('width', 0 + '%')
      data.context.html(@getLoadingElement())

  getLoadingElement: (text = 'Processing...' ) ->
    '<div class="thumbnail-processing"><div class="loading-icon"></div><div class="loading-text">' + text + '</div></div>'

  multiplePhoto: =>
    @sortable.length > 0

  singlePhotoExists: =>
    @uploaded.find('img').length > 0

  replaceExistingImg: (data) =>
    @uploaded.find('img').attr('src', data.result.url)

  addImg: (data) =>
    result = jQuery.parseJSON(data.result)
    if !result
      result = jQuery.parseJSON($('pre', data.result).text())
    data.result = result
    deleteLink = $('<a data-url="' + data.result.destroy_url + '" class="badge delete-photo delete-photo-thumb photo-action">Delete</a>')
    cropLink = $('<a href="' + data.result.resize_url + '" rel="modal.sign-up-modal"  data-id="photo-' + data.result.id + '" class="badge resize-photo photo-action">Rotate & Crop</a>')
    data.context.html('<img src="' + data.result.url + '">')
    data.context.append(deleteLink)
    data.context.append(cropLink)
    if @multiplePhoto()
      data.context.append($('<span>').addClass('photo-position badge badge-inverse').text(@getLastPosition()))
      template_input = @container.find('#photo-item-input-template')
      input = $("<input type='text'>").attr('name', template_input.attr('name')).attr('placeholder', template_input.attr('placeholder')).attr('data-number', template_input.attr('data-number'))
      last_input = @container.find('input[data-number]').eq(-1)
      data_number = parseInt(last_input.attr('data-number')) + 1
      input.attr('data-number', data_number)
      name_prefix = input.attr('name') + '[' + data_number + ']'
      input.attr('name', name_prefix + '[caption]')
      data.context.append(input)
      hidden = $('<input type="hidden">')
      hidden_position = hidden.clone().attr('name', "#{name_prefix}[position]").val(@getLastPosition()).addClass('photo-position-input')
      data.context.attr('id', "photo-#{data.result.id}")
      data.context.append(hidden_position)
      hidden_id = hidden.clone().attr('name', "#{name_prefix}[id]").val(data.result.id)
      data.context.append(hidden_id)

  getLastPosition: ->
    @sortable.find('.photo-item').length

  reorderSortableList: ->
    i = 0
    for index, el of @sortable.sortable('toArray')
      if el != '' and $("##{el}.photo-item").length > 0
        $("##{el}").find('.photo-position-input').val(i)
        $("##{el}").find('.photo-position').text(parseInt(i) + 1)
        i++
