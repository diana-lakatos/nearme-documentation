var AttachmentInput,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.iframe-transport.js');

require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.fileupload.js');

AttachmentInput = function() {
  function AttachmentInput(input) {
    this.listenToParamsChange = bind(this.listenToParamsChange, this);
    this.listenToFileChange = bind(this.listenToFileChange, this);
    this.fileInput = $(input);
    this.container = this.fileInput.closest('.form-group');
    this.isMultiple = !!this.fileInput.attr('multiple');
    this.isJsUpload = !!this.fileInput.data('upload-url');
    this.objectName = this.fileInput.data('object-name');
    this.label = this.container.find('label');
    this.collection = this.container.find('[data-attachment-collection]');
    this.preventEarlySubmission();
    this.processing = 0;
    this.bindEvents();
    if (this.isJsUpload) {
      this.initializeFileUpload();
    }
  }

  AttachmentInput.prototype.bindEvents = function() {
    this.listenToDeleteFile();
    if (this.isJsUpload) {
      this.listenToFormSubmit();
    }
    if (this.isJsUpload) {
      this.listenToParamsChange();
    }
    if (!this.isJsUpload) {
      return this.listenToFileChange();
    }
  };

  AttachmentInput.prototype.listenToFileChange = function() {
    return this.fileInput.on(
      'change',
      function(_this) {
        return function() {
          return _this.updateLabelStatic();
        };
      }(this)
    );
  };

  AttachmentInput.prototype.listenToParamsChange = function() {
    this.collection.on(
      'change',
      'select[data-attachment-property]',
      function(_this) {
        return function(e) {
          return _this.updateAttachmentProperty(e.target);
        };
      }(this)
    );
    return this.collection.on(
      'blur',
      'input[data-attachment-property]',
      function(_this) {
        return function(e) {
          return _this.updateAttachmentProperty(e.target);
        };
      }(this)
    );
  };

  AttachmentInput.prototype.updateAttachmentProperty = function(control) {
    var data, key, url, value;
    control = $(control);
    key = control.data('attachment-property');
    value = control.val();
    url = control.closest('[data-attachment]').data('update-url');

    /*
     * TODO - this should be generic rather than specific to seller attachments
     */
    data = { 'seller_attachment': {} };
    data.seller_attachment[key] = value;
    return $.ajax({ url: url, method: 'PUT', data: data });
  };

  AttachmentInput.prototype.initializeFileUpload = function() {
    return this.fileInput.fileupload({
      url: this.fileInput.data('upload-url'),
      paramName: this.fileInput.data('upload-name'),
      dataType: 'html',
      dropZone: this.container,
      formData: function(form) {
        var params;
        params = form.clone();
        params.find('input[name=_method]').remove();
        return params.serializeArray();
      },
      add: function(_this) {
        return function(e, data) {
          if (_this.isMultiple === false) {
            _this.collection.find('[data-attachment]').each(function(index, item) {
              return _this.removeItem(item);
            });
          }
          _this.processing += 1;
          _this.updateLabel();
          return data.submit();
        };
      }(this),
      done: function(_this) {
        return function(e, data) {
          return _this.createItem(data.result);
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
          _this.processing -= 1;
          return _this.updateLabel();
        };
      }(this)
    });
  };

  AttachmentInput.prototype.createItem = function(html) {
    var item;
    item = $(html);
    this.collection.append(item);
    return $('html').trigger('selects.init.forms', [ item ]);
  };

  AttachmentInput.prototype.removeItem = function(item) {
    var trigger, url;
    item = $(item);
    trigger = item.find('[data-delete]');
    url = trigger.data('url');
    item.addClass('deleting');
    this.processingFiles += 1;
    return $.ajax({
      url: url,
      method: 'post',
      data: { _method: 'delete' },
      success: function(_this) {
        return function() {
          item.remove();
          return _this.processingFiles -= 1;
        };
      }(this)
    });
  };

  AttachmentInput.prototype.listenToDeleteFile = function() {
    return this.collection.on(
      'click',
      '[data-delete]',
      function(_this) {
        return function(e) {
          var labelConfirm, trigger;
          e.preventDefault();
          trigger = $(e.target).closest('[data-delete]');
          labelConfirm = trigger.data('label-confirm');
          if (!confirm(labelConfirm)) {
            return;
          }
          return _this.removeItem(trigger.closest('[data-attachment]'));
        };
      }(this)
    );
  };

  AttachmentInput.prototype.listenToFormSubmit = function() {
    return this.container.parents('form').on(
      'submit',
      function(_this) {
        return function(e) {
          if (_this.processingFiles > 0) {
            return e.preventDefault();
          }
        };
      }(this)
    );
  };

  AttachmentInput.prototype.updateLabel = function() {
    if (this.isJsUpload) {
      return this.updateLabelJS();
    } else {
      return this.updateLabelStatic();
    }
  };

  AttachmentInput.prototype.updateLabelStatic = function() {
    var matches, output;
    if (this.fileInput.get(0).files) {
      output = [];
      _.each(this.fileInput.get(0).files, function(item) {
        return output.push(item.name);
      });
      output = output.join(', ');
    } else {
      matches = this.fileInput.val().match(/\\([^\\]+)$/i);
      output = matches[1];
    }
    if (!output) {
      output = this.defaultLabel();
    }
    return this.label.find('.add-label').html(output);
  };

  AttachmentInput.prototype.updateLabelJS = function() {
    var text;
    switch (this.processing) {
      case 0:
        text = this.defaultLabel();
        break;
      case 1:
        text = 'Uploading file...';
        break;
      default:
        text = 'Uploading ' + this.processing + ' files...';
    }
    this.label.find('.add-label').html(text);
    return this.label.toggleClass('active-upload', this.processing > 0);
  };

  AttachmentInput.prototype.defaultLabel = function() {
    if (this.isMultiple) {
      return 'Add file(s)...';
    } else {
      return 'Select file...';
    }
  };

  AttachmentInput.prototype.preventEarlySubmission = function() {
    return this.container.parents('form').on(
      'submit',
      function(_this) {
        return function() {
          if (_this.processing > 0) {
            alert('Please wait until all files are uploaded before submitting.');
            return false;
          }
        };
      }(this)
    );
  };

  return AttachmentInput;
}();

module.exports = AttachmentInput;
