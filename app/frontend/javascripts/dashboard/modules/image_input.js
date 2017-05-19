var ImageInput,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('jquery-ui/ui/widgets/sortable');

require('swipebox/src/js/jquery.swipebox');

require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.iframe-transport.js');

require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.fileupload.js');

require('../../vendor/jquery-dragster');

ImageInput = function() {
  function ImageInput(input) {
    this.updateProcessing = bind(this.updateProcessing, this);
    console.log('DNM :: ImageInput :: Initializing');
    this.fileInput = $(input);
    this.container = this.fileInput.closest('.form-group');
    this.form = this.fileInput.closest('form');
    this.fieldWrapper = this.fileInput.closest('.input-preview');
    this.isMultiple = !!this.fileInput.attr('multiple');
    this.isJsUpload = !!this.fileInput.data('upload-url');
    this.hasCaptions = !!this.fileInput.data('has-captions');
    this.captionPlaceholder = this.fileInput.data('caption-placeholder');
    this.objectName = this.fileInput.data('object-name');
    this.modelName = this.fileInput.data('model-name');
    this.label = this.container.find('label');
    this.dropzoneLabel = this.fileInput.data('dropzone-label');
    this.updateOnSaveLabel = this.fileInput.data('upload-on-save-label');
    this.collection = this.container.find('[data-image-collection]');
    this.isSortable = !!this.collection.attr('data-sortable');
    this.allowedFileTypes = [ 'jpg', 'jpeg', 'gif', 'png' ];
    this.processing = 0;
    this.initializePreview();
    if (this.isSortable) {
      this.initializeSortable();
    }
    if (this.isJsUpload) {
      this.initializeFileUpload();
      this.initializeDraggable();
      this.initializeProgressbar();
    }
    this.bindEvents();
  }

  ImageInput.prototype.bindEvents = function() {
    this.listenToDeletePhoto();
    this.listenToEditPhoto();
    this.listenToDragFile();
    this.listenToPreviewEvents();
    this.preventEarlySubmission();
    if (!this.isJsUpload && Modernizr.filereader) {
      return this.listenToInputChange();
    }
  };

  ImageInput.prototype.initializePreview = function() {
    this.preview = $(
      '<div class="form-images__preview"><figure><img src=""></figure><span class="form-images__preview__close">Close preview</span></div>'
    );
    return this.preview.appendTo('body');
  };

  ImageInput.prototype.showPreview = function(url) {
    this.preview.find('figure').html("<img src='" + url + "'>");
    this.preview.addClass('preview--active');

    /*
     * close on ESC
     */
    return $('body').on(
      'keydown.preview',
      function(_this) {
        return function(e) {
          if (e.which === 27) {
            return _this.hidePreview();
          }
        };
      }(this)
    );
  };

  ImageInput.prototype.hidePreview = function() {
    this.preview.removeClass('preview--active');

    /*
     * remove close on ESC event
     */
    return $('body').off('keydown.preview');
  };

  ImageInput.prototype.listenToPreviewEvents = function() {
    this.preview.on(
      'click',
      function(_this) {
        return function() {
          return _this.hidePreview();
        };
      }(this)
    );
    return this.container.on(
      'click',
      '.action--preview',
      function(_this) {
        return function(e) {
          var url;
          e.preventDefault();
          e.stopPropagation();
          url = $(e.target).closest('a').attr('href');
          return _this.showPreview(url);
        };
      }(this)
    );
  };

  ImageInput.prototype.validateFileType = function(file) {
    var types;
    types = $.map(this.allowedFileTypes, function(item) {
      return 'image/' + item;
    });
    return $.inArray(file.type, types) > -1;
  };

  /*
   * It will show the dropzone on file dragging to browser window
   */
  ImageInput.prototype.listenToDragFile = function() {
    return $(window).dragster({
      enter: function(_this) {
        return function() {
          return _this.fieldWrapper.addClass('drag-active');
        };
      }(this),
      leave: function(_this) {
        return function() {
          return _this.fieldWrapper.removeClass('drag-active');
        };
      }(this),
      drop: function(_this) {
        return function() {
          return _this.fieldWrapper.removeClass('drag-active');
        };
      }(this)
    });
  };

  ImageInput.prototype.listenToDataUrlPreview = function() {
    return this.container.on('click', 'action--dataurl-preview', function(e) {
      var url;
      url = $(e.target).closest('a').find('img').attr('src');
      return this.showPreview(url);
    });
  };

  ImageInput.prototype.listenToInputChange = function() {
    var reader;
    reader = new FileReader();
    reader.onloadend = function(_this) {
      return function() {
        return _this.updatePreview({ dataUrl: reader.result });
      };
    }(this);
    return this.fileInput.on('change', function() {
      var file;
      if (this.isMultiple) {
        throw new Error('Support for multiple files without XHR is not implemented');
      } else {
        file = this.files[0];
        if (file) {
          return reader.readAsDataURL(file);
        }
      }
    });
  };

  ImageInput.prototype.initializeDraggable = function() {
    this.fieldWrapper.addClass('draggable-enabled');
    this.dropzone = $(
      "<div class='drop-zone'><div class='text'>" + this.dropzoneLabel + '</div></div>'
    );
    return this.dropzone.prependTo(this.fieldWrapper);
  };

  ImageInput.prototype.initializeProgressbar = function() {
    this.fieldWrapper.prepend(
      "<div class='file-progress'><div class='bar'></div><div class='text'></div></div>"
    );
    return this.uploadLabelContainer = this.container.find('.file-progress  .text');
  };

  ImageInput.prototype.initializeFileUpload = function() {
    return this.fileInput.fileupload({
      url: this.fileInput.data('upload-url'),
      paramName: this.fileInput.data('upload-name'),
      dataType: 'json',
      dropZone: this.dropZone,
      formData: function(form) {
        var params;
        params = form.clone();
        params.find('input[name=_method]').remove();
        return params.serializeArray();
      },
      start: function(_this) {
        return function() {
          return _this.fieldWrapper.addClass('progress--active');
        };
      }(this),
      stop: function(_this) {
        return function() {
          return _this.fieldWrapper.removeClass('progress--active');
        };
      }(this),
      add: function(_this) {
        return function(e, data) {
          var file;
          _this.updateProcessing(1);
          file = data.files[0];
          if (_this.validateFileType(file)) {
            _this.updateLabel();
            return data.submit();
          } else {
            return alert(
              file.name + ' seems to not be an image - please select gif, jpg, jpeg or png file'
            );
          }
        };
      }(this),
      done: function(_this) {
        return function(e, data) {
          if (_this.isMultiple) {
            _this.collection.append(_this.createCollectionItem(data.result));
            _this.reorderSortableList();
          } else {
            _this.updatePreview(data.result);
          }
          return _this.rebindEvents();
        };
      }(this),
      fail: function(e, data) {
        window.alert('Unable to process this request, please try again.');
        if (window.Raygun) {
          return window.Raygun.send(data.errorThrown, data.textStatus);
        }
      },
      always: function(_this) {
        return function() {
          _this.updateProcessing(-1);
          return _this.updateLabel();
        };
      }(this)
    });
  };

  ImageInput.prototype.updatePreview = function(data) {
    var a, options, preview;
    preview = this.fieldWrapper.find('.preview').empty();
    if (preview.length === 0) {
      preview = $('<div class="preview"/>').prependTo(this.fieldWrapper);
    }
    preview.html('<figure/><div class="form-images__options"/>');
    options = preview.find('.form-images__options');
    if (data.sizes != null) {
      preview
        .find('figure')
        .append(
          '<a href="' + data.sizes.full.url + '" class=\'action--preview\'><img src="' +
            data.sizes.space_listing.url +
            '"></a>'
        );
    }
    if (data.url != null) {
      preview
        .find('figure')
        .append(
          '<a href="' + data.url + '" class=\'action--preview\'><img src="' + data.url + '"></a>'
        );
    }
    if (data.dataUrl != null) {
      a = $('<a class="action--preview"/>');
      a.attr('href', data.dataUrl);
      a.append('<img src="' + data.dataUrl + '">');
      preview.find('figure').append(a);
    }
    if (data.resize_url != null) {
      options.append(
        "<button type='button' class='action--edit' data-edit data-url='" + data.resize_url +
          "'>Crop & Resize</button>"
      );
    }
    if (data.destroy_url != null) {
      options.append(
        "<button type='button' class='action--delete' data-delete data-url='" + data.destroy_url +
          "' data-label-confirm='Are you sure you want to delete this image?'>Remove</button>"
      );
    }
    if (!this.isJsUpload) {
      return preview.append('<small>' + this.updateOnSaveLabel + '</small>');
    }
  };

  ImageInput.prototype.initializeSortable = function() {
    this.collection.sortable({
      stop: function(_this) {
        return function() {
          return _this.reorderSortableList();
        };
      }(this),
      placeholder: 'photo-placeholder',
      handle: '.sort-handle',
      cancel: 'input',
      scroll: false
    });
    return this.reorderSortableList();
  };

  ImageInput.prototype.rebindEvents = function() {
    return this.collection.find('.action--preview').swipebox();
  };

  ImageInput.prototype.createCollectionItem = function(data) {
    var container, options;
    container = $('<li data-photo-item/>');
    container.append(
      '<a href="' + data.sizes.full.url + '" class=\'action--preview\'><img src="' +
        data.sizes.space_listing.url +
        '"></a>'
    );
    options = $('<div class="form-images__options">').appendTo(container);
    if (data.resize_url) {
      options.append(
        "<button type='button' class='action--edit' data-edit data-url='" + data.resize_url +
          "'>Crop & Resize</button>"
      );
    }
    if (data.destroy_url) {
      options.append(
        "<button type='button' class='action--delete' data-delete data-url='" + data.destroy_url +
          "' data-label-confirm='Are you sure you want to delete this image?'>Remove</button>"
      );
    }
    if (this.isSortable) {
      container.append('<span class="sort-handle"/>');
      container.append(
        "<input type='hidden' name='" + this.objectName + '[' + this.modelName +
          "_ids][]' value='" +
          data.id +
          "'>"
      );
      container.append(
        "<input type='hidden' name='" + this.objectName + '[' + this.modelName + 's_attributes][' +
          data.id +
          "][id]' value='" +
          data.id +
          "'>"
      );
      container.append(
        "<input type='hidden' name='" + this.objectName + '[' + this.modelName + 's_attributes][' +
          data.id +
          "][position]' value='' class='photo-position-input'>"
      );
    }
    if (this.hasCaptions) {
      container.append(
        "<span class='caption'><input type='text' name='" + this.objectName + '[' + this.modelName +
          's_attributes][' +
          data.id +
          "][caption]' value='' placeholder='" +
          this.captionPlaceholder +
          "'></span>"
      );
    }
    return container;
  };

  ImageInput.prototype.listenToDeletePhoto = function() {
    return this.container.on(
      'click',
      '[data-delete]',
      function(_this) {
        return function(e) {
          var labelConfirm, photo, trigger, url;
          e.preventDefault();
          _this.updateProcessing(1);
          trigger = $(e.target).closest('[data-delete]');
          url = trigger.data('url');
          labelConfirm = trigger.data('label-confirm');
          if (!confirm(labelConfirm)) {
            return;
          }
          photo = trigger.closest('[data-photo-item], .preview').addClass('deleting');
          return $.post(url, { _method: 'delete' }, function() {
            photo.remove();
            _this.updateProcessing(-1);
            return _this.reorderSortableList();
          });
        };
      }(this)
    );
  };

  ImageInput.prototype.listenToEditPhoto = function() {
    return this.container.on('click', '[data-edit]', function(e) {
      var trigger, url;
      e.preventDefault();
      trigger = $(e.target).closest('[data-edit]');
      url = trigger.data('url');
      return $(document).trigger('load:dialog.nearme', [ { url: url } ]);
    });
  };

  ImageInput.prototype.updateLabel = function() {
    var text;
    switch (this.processing) {
      case 0:
        text = 'All files uploaded';
        break;
      case 1:
        text = 'Uploading photo...';
        break;
      default:
        text = 'Uploading ' + this.processing + ' photos...';
    }
    return this.uploadLabelContainer.html(text);
  };

  ImageInput.prototype.updateProcessing = function(change) {
    this.processing = this.processing + change;
    return this.form.data('processing', this.processing > 0);
  };

  ImageInput.prototype.preventEarlySubmission = function() {
    return this.form.on(
      'submit',
      function(_this) {
        return function(e) {
          if (_this.form.data('processing')) {
            alert('Please wait until all files are uploaded before submitting.');
            e.preventDefault();
            return e.stopPropagation();
          }
        };
      }(this)
    );
  };

  ImageInput.prototype.reorderSortableList = function() {
    if (!this.isSortable) {
      return;
    }
    this.collection.sortable('refresh');
    return this.collection.find('li').each(function(index, el) {
      return $(el).find('.photo-position-input').val(index);
    });
  };

  return ImageInput;
}();

module.exports = ImageInput;
