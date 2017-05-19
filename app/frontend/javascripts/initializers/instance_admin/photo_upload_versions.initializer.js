var els = $('[data-photo-uploader-versions]');
if (els.length > 0) {
  require.ensure('../../instance_admin/forms/photo_upload_versions', function(require) {
    var PhotoUploadVersions = require('../../instance_admin/forms/photo_upload_versions');
    return new PhotoUploadVersions();
  });
}
