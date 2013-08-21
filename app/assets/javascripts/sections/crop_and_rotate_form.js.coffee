class @CropAndRotateForm extends @ModalForm

  constructor: (@container)->
    @form = @container.find('form')
    @image = $('#photo_crop')
    super(@container, @form)

  bindEvents: ->
    @bindRotationHandler()
    @bindCropHandler()

  bindCropHandler: ->
    self = this
    @image.Jcrop
      onSelect: (c)=>
        if c.h != 0 and c.w != 0
          @crop = c
        else
          @crop = null
      trueSize: [@image.data('original-w'), @image.data('original-h')]
      aspectRatio: 16/10
    , () ->
      DNM.PhotoCrop = this
      self.container.find('.jcrop-holder img').rotate(self.angle)
      this.setSelect self.imageCropCoords() if self.imageCropped()


  bindRotationHandler: ->
    @angle = @image.data('rotate') or 0
    $('.rotate-photo').on 'click', (e)=>
      @angle += 90
      @container.find('.jcrop-holder img').rotate(@angle)
      e.preventDefault()


  updateModalOnSubmit: =>
    @form.submit =>
      Modal.load { type: "POST", url: @form.attr("action"), data: @getData()}, null, ()->
        PhotoUploader.updateImages([Modal.currentData.id])
      false

  imageCropped: ->
    @image.data('w')? and @image.data('h')? and @image.data('x') and @image.data('y')

  imageCropCoords: ->
    [@image.data('x'), @image.data('y'), @image.data('x') + @image.data('w'), @image.data('y') + @image.data('h')]

  getData: ->
    data = {}
    if @angle != 0
      data['rotate'] = @angle
    if @crop != null
      data['crop'] = @crop
    data
