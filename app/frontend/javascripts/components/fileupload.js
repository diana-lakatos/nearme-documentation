var CkfileCollection, Fileupload, PhotoCollection;

require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.iframe-transport.js');

require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.fileupload.js');

CkfileCollection = require('./ckfile/collection');

PhotoCollection = require('./photo/collection');

Fileupload = function() {
  function Fileupload(fileInputWrapper) {
    this.fileInputWrapper = $(fileInputWrapper);
    this.fileInput = this.fileInputWrapper.find('input[type="file"]');
    this.file_types = this.fileInput.attr('data-file-types');
    this.upload_type = this.fileInput.attr('data-upload-type');
    this.files_container = this.fileInput.attr('data-files-container');
    this.wrong_file_message = this.fileInput.attr('data-wrong-file-message');
    this.append_result = this.fileInput.attr('data-append-result') === '1' ? true : false;
    this.preventEarlySubmission();
    this.processing = 0;
    if (this.upload_type === 'ckfile') {
      this.fileCollection = new CkfileCollection($(this.files_container));
      this.dataType = 'html';
    } else if (this.upload_type === 'attachment') {
      this.dataType = 'html';
    } else {
      this.fileCollection = new PhotoCollection(this.fileInputWrapper.parent());
      this.dataType = 'json';
    }
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
          var file, progressBar, types;
          _this.processing += 1;
          if (_this.file_types && _this.file_types !== '') {
            types = new RegExp(_this.file_types, 'i');
          } else {
            types = /(\.|\/)(gif|jpe?g|png|ico)$/i;
          }
          file = data.files[0];
          if (types.test(file.type) || types.test(file.name)) {
            progressBar = _this.fileInputWrapper.find('div[data-progress-container]:first').clone();
            progressBar.find('span[data-filename]').text(file.name);
            progressBar.show();
            _this.fileInputWrapper.append(progressBar);
            data.progressBar = progressBar;
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
      progress: function(e, data) {
        var progress;
        if (data.progressBar) {
          progress = parseInt(data.loaded / data.total * 100, 10);
          return data.progressBar.find('div[data-progress-bar]').css('width', progress + '%');
        }
      },
      done: function(_this) {
        return function(e, data) {
          var fileIndex;
          if (_this.upload_type === 'attachment') {
            return _this.fileInputWrapper.parent().find('[data-uploaded]').html(data.result);
          } else {
            fileIndex = _this.fileCollection.add();
            return _this.fileCollection.update(fileIndex, data.result, _this.append_result);
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
        return function(e, data) {
          _this.processing -= 1;
          return data.progressBar.remove();
        };
      }(this)
    });
  }

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
