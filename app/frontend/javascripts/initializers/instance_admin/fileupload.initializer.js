var els = $('div[data-fileupload-wrapper]');
if (els.length > 0) {
  require.ensure('../../components/fileupload', function(require) {
    var Fileupload = require('../../components/fileupload');
    els.each(function() {
      return new Fileupload(this);
    });
  });
}

/* Display file name on upload */
$('.upload-file').change(function() {
  $('#' + $(this).attr('name')).append($(this).val().split('\\').pop());
});
