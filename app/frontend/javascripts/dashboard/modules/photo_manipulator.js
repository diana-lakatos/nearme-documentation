var PhotoManipulator,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('cropper/dist/cropper');

PhotoManipulator = function() {
  function PhotoManipulator(form) {
    this.bindRotationHandler = bind(this.bindRotationHandler, this);
    this.onCropEnd = bind(this.onCropEnd, this);
    this.setOriginalParameters = bind(this.setOriginalParameters, this);
    this.form = $(form);
    this.image = this.form.find('img[data-image]').eq(0);
    this.aspectRatio = this.image.data('aspect-ratio');
    this.originalCrop = this.image.data('crop');
    this.originalRotate = this.image.data('rotate') || 0;
    this.bindEvents();
  }

  PhotoManipulator.prototype.bindEvents = function() {
    this.bindRotationHandler();
    this.setOriginalParameters();
    return this.form.on(
      'submit',
      function(_this) {
        return function(e) {
          var ajaxOptions;
          e.preventDefault();
          ajaxOptions = {
            type: 'post',
            url: _this.form.attr('action'),
            data: { _method: 'put', crop: _this.crop, rotate: _this.angle }
          };
          return $(document).trigger('load:dialog.nearme', [ ajaxOptions ]);
        };
      }(this)
    );
  };

  PhotoManipulator.prototype.setOriginalParameters = function() {
    var options;
    options = { aspectRatio: this.aspectRatio, cropend: this.onCropEnd, scalable: false };
    if (this.imageCropped() || this.originalRotate !== 0) {
      options.data = {};
      if (this.originalRotate !== 0) {
        options.data['rotate'] = this.originalRotate;
      }
      if (this.imageCropped) {
        options.data['x'] = parseInt(this.originalCrop['x'], 10);
        options.data['y'] = parseInt(this.originalCrop['y'], 10);
        options.data['width'] = parseInt(this.originalCrop['w'], 10);
        options.data['height'] = parseInt(this.originalCrop['h'], 10);
      }
    }
    return setTimeout(
      function(_this) {
        return function() {
          return _this.image.cropper(options);
        };
      }(this),
      100
    );
  };

  PhotoManipulator.prototype.onCropEnd = function() {
    var data;
    data = this.image.cropper('getData', true);
    return this.crop = {
      x: data.x,
      y: data.y,
      x2: data.x + data.width,
      y2: data.y + data.height,
      w: data.width,
      h: data.height
    };
  };

  PhotoManipulator.prototype.bindRotationHandler = function() {
    this.angle = this.originalRotate;
    return $('[data-rotate-photo]').on(
      'click',
      function(_this) {
        return function() {
          _this.angle = _this.angle + 90;
          if (_this.angle === 360) {
            _this.angle = 0;
          }
          _this.image.cropper('rotate', 90);

          /*
         * We do this because after a rotate the cropping area is cropping something else
         */
          return setTimeout(
            function() {
              return _this.onCropEnd();
            },
            100
          );
        };
      }(this)
    );
  };

  PhotoManipulator.prototype.imageCropped = function() {
    return this.originalCrop['x2'] != null && this.originalCrop['y2'] != null &&
      this.originalCrop['x'] != null &&
      this.originalCrop['y'] != null;
  };

  return PhotoManipulator;
}();

module.exports = PhotoManipulator;
