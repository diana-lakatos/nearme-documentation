var Modal,
  PhotoManipulator,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('../../vendor/jQueryRotate');

require('jquery-jcrop/js/jquery.Jcrop');

Modal = require('../modal');

PhotoManipulator = function() {
  function PhotoManipulator(form, options) {
    if (options == null) {
      options = {};
    }
    this.bindRotationHandler = bind(this.bindRotationHandler, this);
    this.bindCropHandler = bind(this.bindCropHandler, this);
    this.form = form;
    this.image = form.find('img[data-image]').eq(0);
    this.aspectRatio = options['aspectRatio'];
    this.original_crop = this.image.data('crop');
    this.bindEvents();
  }

  PhotoManipulator.prototype.bindEvents = function() {
    this.bindRotationHandler();
    this.bindCropHandler();
    return this.form.on(
      'submit',
      function(_this) {
        return function(e) {
          e.preventDefault();
          return Modal.load({
            type: 'POST',
            url: _this.form.attr('action'),
            data: { _method: 'put', crop: _this.crop, rotate: _this.angle }
          });
        };
      }(this)
    );
  };

  PhotoManipulator.prototype.bindCropHandler = function() {
    var self;
    this.crop = null;
    self = this;
    return this.image.Jcrop(
      {
        onSelect: function(_this) {
          return function(c) {
            if (c.h !== 0 && c.w !== 0) {
              return _this.crop = c;
            } else {
              return _this.crop = null;
            }
          };
        }(this),
        aspectRatio: this.aspectRatio,
        trueSize: this.image.data('original-dimensions'),
        bgColor: 'none'
      },
      function() {
        window.DNMPhotoCrop = this;
        self.form.find('.jcrop-holder img').rotate(self.angle);
        if (self.imageCropped()) {
          return this.setSelect(self.imageCropCoords());
        }
      }
    );
  };

  PhotoManipulator.prototype.bindRotationHandler = function() {
    this.angle = this.image.data('rotate') || 0;
    return $('.rotate-photo').on(
      'click',
      function(_this) {
        return function(e) {
          _this.angle = (_this.angle + 90) % 360;
          _this.form.find('.jcrop-holder img').rotate(_this.angle);
          return e.preventDefault();
        };
      }(this)
    );
  };

  PhotoManipulator.prototype.imageCropCoords = function() {
    return [
      this.original_crop['x'],
      this.original_crop['y'],
      this.original_crop['x2'],
      this.original_crop['y2']
    ];
  };

  PhotoManipulator.prototype.imageCropped = function() {
    return this.original_crop['x2'] != null && this.original_crop['y2'] != null &&
      this.original_crop['x'] != null &&
      this.original_crop['y'] != null;
  };

  return PhotoManipulator;
}();

module.exports = PhotoManipulator;
