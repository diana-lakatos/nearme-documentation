/* Display file name on upload */
$('.upload-file').change(function() {
  $('#' + $(this).attr('name')).append($(this).val().split('\\').pop());
});
