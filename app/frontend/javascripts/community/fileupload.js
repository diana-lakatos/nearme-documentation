var Fileupload, PhotoCollection;

require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.iframe-transport.js');

require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.fileupload.js');

PhotoCollection = require('./photo/collection');

Fileupload = function() {
  function Fileupload(fileInputWrapper) {
    this.fileInputWrapper = $(fileInputWrapper);
    this.fileInput = this.fileInputWrapper.find('input[type="file"]');
    this.file_types = this.fileInput.attr('data-file-types');
    this.upload_type = this.fileInput.attr('data-upload-type');
    this.files_container = this.fileInput.attr('data-files-container');
    this.wrong_file_message = this.fileInput.attr('data-wrong-file-message');
    this.label = this.fileInputWrapper.find('label');
    this.preventEarlySubmission();
    this.processing = 0;
    this.fileCollection = new PhotoCollection(this.fileInputWrapper.parent());
    this.dataType = 'json';
    this.fileInput.fileupload({
      url: this.fileInputWrapper.data('url'),
      paramName: this.fileInputWrapper.data('name'),
      dataType: this.dataType,
      dropZone: this.fileInputWrapper,
      formData: function(form) {
        var params;
        params = form.clone();
        params.find('input[name=_method]').remove();
        return params.serializeArray();
      },
      add: function(_this) {
        return function(e, data) {
          var file, types;
          _this.processing += 1;
          if (_this.file_types && _this.file_types !== '') {
            types = new RegExp(_this.file_types, 'i');
          } else {
            types = /(\.|\/)(gif|jpe?g|png)$/i;
          }
          file = data.files[0];
          if (types.test(file.type) || types.test(file.name)) {
            _this.updateLabel();
            return data.submit();
          } else {
            if (_this.wrong_file_message && _this.wrong_file_message !== '') {
              return alert(file.name + ' ' + _this.wrong_file_message);
            } else {
              return alert(
                file.name + ' seems to not be an image - please select gif, jpg, jpeg or png file'
              );
            }
          }
        };
      }(this),
      done: function(_this) {
        return function(e, data) {
          var fileIndex;
          if (_this.upload_type === 'attachment') {
            return _this.fileInputWrapper.parent().find('[data-uploaded]').html(data.result);
          } else {
            fileIndex = _this.fileCollection.add();
            return _this.fileCollection.update(fileIndex, data.result);
          }
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
  }

  Fileupload.prototype.updateLabel = function() {
    var defaultLabel, text;
    defaultLabel = this.fileInput.is('[multiple]') ? 'Add photo' : 'Upload photo';
    switch (this.processing) {
      case 0:
        text = defaultLabel;
        break;
      case 1:
        text = 'Uploading photo...';
        break;
      default:
        text = 'Uploading ' + this.processing + ' photos...';
    }
    this.label.html(text);
    return this.label.toggleClass('active', this.processing > 0);
  };

  Fileupload.prototype.preventEarlySubmission = function() {
    return this.fileInputWrapper.parents('form').on(
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

  return Fileupload;
}();

module.exports = Fileupload;
