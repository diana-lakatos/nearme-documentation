$(document).on('init:sellerattachmentaccesslevelselector.nearme', function(event, el) {
  el = el || document;
  require.ensure('../../components/seller_attachment_access_level_selector', function(require) {
    var SellerAttachmentAccessLevelSelector = require(
      '../../components/seller_attachment_access_level_selector'
    );
    return new SellerAttachmentAccessLevelSelector(el);
  });
});
