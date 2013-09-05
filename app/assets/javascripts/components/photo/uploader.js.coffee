class @Photo.Uploader

  constructor : (container) ->
    @container = container
    @fileInput = container.find('.browse-file').eq(0)
    @photoCollection = new Photo.Collection(container)
    @init()
  
  init: ->
    @initializeFileUploader()

  initializeFileUploader : =>

    @fileInput.on 'click', (event) =>
      __insp.push(['tagSession', "photo_upload_clicked"])
      event.preventDefault()
      if @photoCollection.multiplePhoto()
        filepicker.pickMultiple { debug: filepicker.debug_mode }, (inkBlobs) =>
          @createPhotos(inkBlobs)
      else
        filepicker.pick { debug: filepicker.debug_mode }, (inkBlob) =>
          @createPhoto(inkBlob)
        
  createPhotos: (inkBlobs) ->
    for inkBlob in inkBlobs
      @createPhoto(inkBlob)

  createPhoto: (inkBlob) ->
    photo_index = @photoCollection.add()
    $.post(@fileInput.attr('data-url'), @getParamsForCreatePhotoRequest(inkBlob), (data) =>
      @photoCollection.update(photo_index, data)
    )

  getParamsForCreatePhotoRequest: (inkBlob) ->
    params = {}
    params["#{@fileInput.attr('name')}"] = inkBlob.url
    # need to add data-name-prefix to fileinput, because this won't work for avatar 
    if $('#listing_id')
      params["#{$('#listing_id').attr('name')}"] = $('#listing_id').val()
    params
