class @CropAndRotateForm extends @ModalForm

  constructor: (@container)->
    @form = @container.find('form')
    @image = $('#photo_crop')
    super(@container, @form)

  bindEvents: ->
    @image.Jcrop
      onSelect: (c)=>
        if c.h != 0 and c.w != 0
          @crop = c
        else
          @crop = null
      trueSize: [@image.data('w'), @image.data('h')]
      aspectRatio: 16/10
    , () -> DNM.PhotoCrop = this
    @angle = 0
    $('.rotate-photo').on 'click', (e)=>
      @angle += 90
      @container.find('.jcrop-holder img').rotate(@angle)
      e.preventDefault()


  updateModalOnSubmit: =>
    @form.submit =>
      Modal.load { type: "POST", url: @form.attr("action"), data: @getData()}, null, ()->
        PhotoUploader.updateImages([Modal.currentData.id])
      false

  getData: ()->
    data = {}
    if @angle != 0
      data['rotate'] = {angle: @angle}
    if @crop != null
      data['crop'] = @crop
    data
