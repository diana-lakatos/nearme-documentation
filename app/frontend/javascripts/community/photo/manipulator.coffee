require('jquery-jcrop/js/jquery.Jcrop');
Modal = require('../modal')

module.exports = class PhotoManipulator

  constructor: (form, options = {}) ->
    @form = form
    @image = form.find('img[data-image]').eq(0)
    @aspectRatio = options['aspectRatio']
    @original_crop = @image.data('crop')
    @bindEvents()

  bindEvents: ->
    @bindRotationHandler()
    @bindCropHandler()
    @form.on 'submit', (e) =>
      e.preventDefault()
      Modal.load { type: "POST", url: @form.attr("action"), data: { _method: 'put', crop: @crop, rotate: @angle } }

  bindCropHandler: =>
    @crop = null
    self = this
    @image.Jcrop
      onSelect: (c) =>
        if c.h != 0 && c.w != 0
          @crop = c
        else
          @crop = null
      aspectRatio: @aspectRatio

      trueSize: @image.data('original-dimensions')
      bgColor: 'none'
    , ->
      self.form.find('.jcrop-holder img').rotate(self.angle)
      this.setSelect(self.imageCropCoords()) if self.imageCropped()


  bindRotationHandler: =>
    @angle = @image.data('rotate') or 0
    $('.rotate-photo, [data-rotate-photo]').on 'click', (e)=>
      @angle = (@angle + 90) % 360
      @form.find('.jcrop-holder img').rotate(@angle)
      e.preventDefault()

  imageCropCoords: ->
    [@original_crop['x'], @original_crop['y'], @original_crop['x2'], @original_crop['y2']]

  imageCropped: ->
    @original_crop['x2']? and @original_crop['y2']? and @original_crop['x']? and @original_crop['y']?
