var SellerAttachmentAccessLevelSelector;

SellerAttachmentAccessLevelSelector = function() {
  function SellerAttachmentAccessLevelSelector(parentContainer) {
    var instance;
    instance = this;
    if (!parentContainer) {
      parentContainer = $(document);
    }
    $(parentContainer).find('select[data-seller-attachment-access-level]').on('change', function() {
      return instance.bindAttachmentUpdate($(this), 'access_level');
    });
    $(parentContainer).find('input[data-seller-attachment-title]').on('blur', function() {
      return instance.bindAttachmentUpdate($(this), 'title');
    });
  }

  SellerAttachmentAccessLevelSelector.prototype.bindAttachmentUpdate = function(self, paramKey) {
    var params;
    params = {
      url: self.attr('data-seller-attachment-update-url'),
      method: 'PUT',
      'data': { 'seller_attachment': {} }
    };
    params['data']['seller_attachment'][paramKey] = self.val();
    return $.ajax(params);
  };

  return SellerAttachmentAccessLevelSelector;
}();

module.exports = SellerAttachmentAccessLevelSelector;
