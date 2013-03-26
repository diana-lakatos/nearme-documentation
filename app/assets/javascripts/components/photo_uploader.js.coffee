class @PhotoUploader

  @initialize: (scope = $('body')) ->
    $('.fileupload', scope).each (index, element) =>
      new PhotoUploader($(element))

  constructor : (container) ->
    @container = container
    @fileInput = container.find('.browse-file').eq(0)
    @button = container.find('.fileinput-button').eq(0)
    @photos = container.find('.photo-item a')
    @uploaded = container.find('.uploaded').eq(0)
    @init()
  
  init : ->
    @listenToTrigger()
    @listenToDeletePhoto()
    @initializeFileUploader()

  listenToTrigger : ->
    @button.click =>
      @fileInput.trigger 'click'

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
        dataType: 'json',
        add: (e, data) =>
          @add(data)
        ,
        done:  (e, data) =>
          @done(data)
        ,
        progress: (e, data) =>
          @progress(data)
    }

  add: (data) =>
    @setPhotoItem(data.files[0].name)
    data.submit()


  done: (data) =>
    if @singlePhotoExists() && !@multiplePhoto()
      @replaceExistingImg(data)
    else
      @addImg(data)
    @fileInput = @container.find('.browse-file').eq(0)
    @initializeFileUploader()

  progress: (data) =>
    progress = parseInt(data.loaded / data.total * 100, 10)
    @photoItem = @getPhotoItem(data.files[0].name)
    @progressBar = @photoItem.find('.progress').eq(0)
    @progressBar.css('width', progress + '%')
    if progress == 100
      @progressBar.css('width', 0 + '%')
      @photoItem.html(@getLoadingElement())

  getLoadingElement: ->
    '<div class="thumbnail-processing"><div class="loading-icon"></div><div class="loading-text">Thumbnail processing...</div></div>'

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
      @photoItem.append('<div class="progress"><div class="bar"></div></div>')

  multiplePhoto: =>
    @uploaded.find('ul').length > 0

  singlePhotoExists: =>
    @uploaded.find('img').length > 0

  replaceExistingImg: (data) =>
    @uploaded.find('img').attr('src', data.result.url)

  addImg: (data) =>
    href = $('<a data-url="' + data.result.destroy_url + '" class="delete-photo delete-photo-thumb"><span class="ico-trash"></span></a>')
    @photoItem = @getPhotoItem(data.files[0].name)
    @photoItem.html('<img src="' + data.result.url + '">')
    if @multiplePhoto()
      @photoItem.append('<input type="hidden" name="uploaded_photos[]" value="' + data.result.id + '">')

    @photoItem.append(href)

