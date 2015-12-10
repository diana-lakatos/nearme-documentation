require 'cropper/dist/cropper.js'

module.exports = class PhotoManipulator

  constructor: (form) ->
    @form = $(form)
    @image = @form.find('img[data-image]').eq(0)
    @aspectRatio = @image.data('aspect-ratio')
    @originalCrop = @image.data('crop')
    @originalRotate = @image.data('rotate') or 0
    @bindEvents()

  bindEvents: ->
    @bindRotationHandler()
    @bindCropHandler()
    @form.on 'submit', (e) =>
      e.preventDefault()
      ajaxOptions = {
        type: "post",
        url: @form.attr("action"),
        data: {
          _method: 'put',
          crop: @crop,
          rotate: @angle
        }
      }
      $('html').trigger('load.dialog', [ ajaxOptions ])

  bindCropHandler: =>
    options = {
      aspectRatio: @aspectRatio
      cropend: @onCropEnd
      scalable: false
    }
    options.data = @imageCropCoords() if @imageCropped()

    setTimeout =>
      @image.cropper(options)
    , 100

  onCropEnd: =>
    data = @image.cropper('getData', true)
    @crop = {
      x: data.x
      y: data.y
      x2: data.x + data.width
      y2: data.y + data.height
      w: data.width
      h: data.height
    }

  bindRotationHandler: =>
    @angle = @originalRotate
    $('[data-rotate-photo]').on 'click', ()=>
      @angle = (@angle + 90)
      @angle = 0 if @angle is 360
      @image.cropper('rotate', 90)

  imageCropCoords: ->
    {
      x: parseInt(@originalCrop['x'], 10)
      y: parseInt(@originalCrop['y'], 10)
      width: parseInt(@originalCrop['w'], 10)
      height: parseInt(@originalCrop['h'], 10)
      rotate: @originalRotate
    }

  imageCropped: ->
    @originalCrop['x2']? and @originalCrop['y2']? and @originalCrop['x']? and @originalCrop['y']?
