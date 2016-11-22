// Graceful degradation for missing inline_labels
// Make the original label visible
$('.control-group.boolean .controls label.checkbox').each(function() {
  try {
    var text = $(this).html();
    if(text.match(/^\s*<[^<>]+>\s*$/)) {
      $(this).parents('.control-group.boolean').find('label.boolean.control-label').show();
    }
  } catch(e) {
    // Avoid graceful degradation code from impacting page
    // errors, if present are not treated
  }
});
