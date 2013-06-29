class @PhotoUploader

  @initialize: (scope = $('body')) ->
    $('.fileupload', scope).each (index, element) =>
      new PhotoUploader($(element))

  constructor : (container) ->
    @container = container
    @fileInput = container.find('.browse-file').eq(0)
    @photos = container.find('.photo-item a')
    @uploaded = container.find('.uploaded').eq(0)
    @init()
  
  init : ->
    @listenToDeletePhoto()
    @initializeFileUploader()

  listenToDeletePhoto: ->
    @uploaded.on 'click', '.delete-photo', (event) ->
      url = $(this).attr("data-url")
      link = $(this)
      if confirm("Are you sure you want to delete this Photo?")
        $.post link.attr("data-url"), { _method: 'delete' }, ->
          link.closest(".photo-item").remove()
      return false

  initializeFileUploader : =>
    @fileInput.fileupload {
        add: (e, data) =>
          @add(data)
        ,
        done:  (e, data) =>
          data.result = @parseResult(data)
          @done(data)
        ,
        progress: (e, data) =>
          data.result = @parseResult(data)
          @progress(data)
    }

  add: (data) =>
    @setPhotoItem(@getUniqueString(data))
    data.submit()

  parseResult: (data) ->
    if $.browser.msie
      result_to_parse = $('pre', data.result).text()
    else
      result_to_parse = data.result
    jQuery.parseJSON(result_to_parse)

  done: (data) =>
    if @singlePhotoExists() && !@multiplePhoto()
      @replaceExistingImg(data)
    else
      @addImg(data)
    @fileInput = @container.find('.browse-file').eq(0)
    @initializeFileUploader()

  progress: (data) =>
    progress = parseInt(data.loaded / data.total * 100, 10)
    @photoItem = @getPhotoItem(@getUniqueString(data))
    @progressBar = @photoItem.find('.progress .bar').eq(0)
    @progressBar.css('width', progress + '%')
    if progress == 100
      @progressBar.css('width', 0 + '%')
      @photoItem.html(@getLoadingElement())

  getLoadingElement: (text = 'Thumbnail processing...' ) ->
    '<div class="thumbnail-processing"><div class="loading-icon"></div><div class="loading-text">' + text + '</div></div>'

  getPhotoItem: (filename) =>
    $('.photo-item[data-filename="' + filename.hashCode() + '"]').eq(0)

  setPhotoItem: (filename) =>
    if @multiplePhoto()
      @photoItem = $('<li class="photo-item"></li>')
      @uploaded.find('ul').append(@photoItem)
    else
      if @singlePhotoExists()
        @photoItem = @uploaded.find('.photo-item').eq(0)
      else
        @photoItem = $('<div class="photo-item"></div>')
        @uploaded.append(@photoItem)
    @photoItem.attr("data-filename", filename.hashCode())
    @addProgressBar(filename)

  addProgressBar: (filename) ->
    @photoItem = @getPhotoItem(filename)
    if @photoItem.find('.progress').length == 0
      if $.browser.msie
        @photoItem.append(@getLoadingElement('Please wait, the upload process can take a while'))
        @photoItem.append('<div class="progress"><div class="bar"></div></div>')
        @photoItem.find('.progress .bar').css('width', '100%')
      else
        @photoItem.append('<div class="progress"><div class="bar"></div></div>')

  multiplePhoto: =>
    @uploaded.find('ul').length > 0

  singlePhotoExists: =>
    @uploaded.find('img').length > 0

  replaceExistingImg: (data) =>
    @uploaded.find('img').attr('src', data.result.url)

  addImg: (data) =>
    href = $('<a data-url="' + data.result.destroy_url + '" class="delete-photo delete-photo-thumb"><span class="ico-trash"></span></a>')
    @photoItem = @getPhotoItem(@getUniqueString(data))
    @photoItem.html('<img src="' + data.result.url + '">')
    @photoItem.append(href)
    if @multiplePhoto()
      if @container.find('#photo-item-input-template').length > 0
        input = @container.find('#photo-item-input-template').clone()
        input.attr('disabled', false)
        input.attr('type', 'text')
        last_input = @container.find('input[data-number]').eq(-1)
        data_number = parseInt(last_input.attr('data-number')) + 1
        input.attr('data-number', data_number)
        name_prefix = input.attr('name') + '[' + data_number + ']'
        input.attr('name', name_prefix + '[caption]')
        @photoItem.append(input)
        @photoItem.append('<input type="hidden" name="' + name_prefix + '[id]" value="' + data.result.id + '">')
      else
        @photoItem.append('<input type="hidden" name="uploaded_photos[]" value="' + data.result.id + '">')

  getUniqueString: (data) ->
    if $.browser.msie
      data.files[0].name
    else
      data.files[0].lastModifiedDate.toString()
