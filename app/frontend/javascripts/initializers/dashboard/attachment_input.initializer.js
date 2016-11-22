var inputs = $('input[data-attachment-input]');
if (inputs.length > 0) {
  require.ensure('../../dashboard/modules/attachment_input', function(require){
    var AttachmentInput = require('../../dashboard/modules/attachment_input');
    inputs.each(function(){
      return new AttachmentInput(this);
    });
  });
}
