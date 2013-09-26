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
      options = { debug: filepicker.debug_mode, extensions: ['.jpg', '.jpeg', '.gif', '.png']}
      if @photoCollection.multiplePhoto()
        filepicker.pickMultiple options, (inkBlobs) =>
          if Object.prototype.toString.call( inkBlobs ) == '[object Array]'
            @createPhotos(inkBlobs)
          else
            @createPhoto(inkBlobs)
      else
        filepicker.pick options, (inkBlob) =>
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
    # If photos are being added to an existing draft space, we need the draft
    # listng_id in order to associate the photos to it
    listing_id = $('#user_companies_attributes_0_locations_attributes_0_listings_attributes_0_id')
    if listing_id.length > 0
      params["#{listing_id.attr('name')}"] = listing_id.val()
    params
