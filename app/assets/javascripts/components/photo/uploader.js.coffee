class @Photo.Uploader

  constructor : (container) ->
    @container = container
    @fileInput = container.find('.browse-file').eq(0)
    @photoCollection = new Photo.Collection(container)
    @loader = new Search.ScreenLockLoader => $('.loading')
    @processingPhotos = 0
    @formIsSubmitting = false
    @init()
  
  init: ->
    @initializeFileUploader()
    @bindEvents()

  bindEvents: () ->
    @container.parents('form').on 'submit', =>
      @formIsSubmitting = true
      if @processingPhotos > 0
        @loader.show()
        __insp.push(['tagSession', "photo_not_processed_before_submit"])
        @triggerMixpanelPhotoNotProcessedBeforeSubmitEvent()
        false

    $(window).on 'unload', =>
      if @formIsSubmitting and @processingPhotos > 0
        __insp.push(['tagSession', "user_closed_browser_photo_not_processed_before_submit"])
        @triggerMixpanelUserClosedBrowserPhotoNotProcessedBeforeSubmitEvent()


  triggerMixpanelPhotoNotProcessedBeforeSubmitEvent: () ->
    $.post '/event_tracker', event: "photo_not_processed_before_submit" 
  
  triggerMixpanelUserClosedBrowserPhotoNotProcessedBeforeSubmitEvent: () ->
    $.post '/event_tracker', event: "user_closed_browser_photo_not_processed_before_submit" 

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
    @processingPhotos += 1
    photo_index = @photoCollection.add()
    $.post(@fileInput.attr('data-url'), @getParamsForCreatePhotoRequest(inkBlob), (data) =>
      @photoCollection.update(photo_index, data)
      @processingPhotos -= 1
      if @processingPhotos == 0
        @loader.hide()
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
