var PhotoUploadVersions;

PhotoUploadVersions = function() {
  function PhotoUploadVersions() {
    this.initialize();
  }

  PhotoUploadVersions.prototype.initialize = function() {
    this.versions = $('[data-photo-uploader-versions]').data('photo-uploader-versions');
    this.select_photo_uploader = $('select.photo_uploader');
    this.select_versions = $('select.uploader_versions');
    this.select_photo_uploader.on(
      'change',
      function(_this) {
        return function() {
          return _this.updateVersions();
        };
      }(this)
    );
    return this.updateVersions();
  };

  PhotoUploadVersions.prototype.updateVersions = function() {
    var current_versions,
      data,
      default_text,
      i,
      len,
      photo_uploader,
      ref,
      selected_version,
      version;
    photo_uploader = this.select_photo_uploader.val();
    current_versions = this.versions[photo_uploader];
    this.select_versions.empty();
    selected_version = this.select_versions.data('selected');
    ref = Object.keys(current_versions);
    for (i = 0, len = ref.length; i < len; i++) {
      version = ref[i];
      data = current_versions[version];
      default_text = ' (default: ' + data['width'] + 'x' + data['height'] + ' with ' +
        data['transform'] +
        ')';
      if (selected_version === version) {
        this.select_versions.append(
          $('<option selected></option>').attr('value', version).text(version + default_text)
        );
      } else {
        this.select_versions.append(
          $('<option></option>').attr('value', version).text(version + default_text)
        );
      }
    }
    return this.select_versions.trigger('chosen:updated');
  };

  return PhotoUploadVersions;
}();

module.exports = PhotoUploadVersions;
