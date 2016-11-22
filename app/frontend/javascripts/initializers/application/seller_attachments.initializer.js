var els = $('[data-seller-attachable]');
if (els.length > 0) {
  require.ensure('../../sections/seller_attachments_controller', function(require){
    var SellerAttachmentsController = require('../../sections/seller_attachments_controller');
    els.each(function(){
      return new SellerAttachmentsController($(this), { path: $(this).data('seller-attachment-path'), seller_attachable: $(this).data('seller-attachable') });
    });
  });
}



