var DefaultImages;

DefaultImages = function() {
  function DefaultImages() {
    this.initialize();
  }

  DefaultImages.prototype.initialize = function() {
    this.versions = $('[data-photo-uploaders]').data('photo-uploaders');
    this.select_photo_uploader = $('select.photo-uploader');
    this.select_versions = $('select.photo-uploader-versions');
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

  DefaultImages.prototype.updateVersions = function() {
    var current_versions, i, len, photo_uploader, selected_version, version;
    photo_uploader = this.select_photo_uploader.val();
    if (photo_uploader) {
      current_versions = this.versions[photo_uploader];
      this.select_versions.empty();
      selected_version = this.select_versions.data('selected');
      for (i = 0, len = current_versions.length; i < len; i++) {
        version = current_versions[i];
        if (selected_version === version) {
          this.select_versions.append(
            $('<option selected></option>').attr('value', version[1]).text(version[0])
          );
        } else {
          this.select_versions.append(
            $('<option></option>').attr('value', version[1]).text(version[0])
          );
        }
      }
      return this.select_versions.trigger('chosen:updated');
    }
  };

  return DefaultImages;
}();

module.exports = DefaultImages;
