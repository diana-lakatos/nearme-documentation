var SellerAttachmentsController;

SellerAttachmentsController = function() {
  function SellerAttachmentsController(container, seller_attachment_options) {
    this.container = container;
    this.seller_attachment_options = seller_attachment_options != null
      ? seller_attachment_options
      : {};
    this.path = this.seller_attachment_options.path;
    this.tab_header = this.container.find('ul[data-tab-header]');
    this.tab_content = this.container.find('div[data-tab-content]');
    this.seller_attachable = this.seller_attachment_options.seller_attachable;
    $
      .get(this.path, {
        seller_attachable_type: this.seller_attachable.type,
        seller_attachable_id: this.seller_attachable.id
      })
      .success(
        function(_this) {
          return function(response) {
            var tab_content;
            if (response.tab_header !== '') {
              _this.tab_header.append(response.tab_header);
              tab_content = $(response.tab_content);
              return _this.tab_content.append(tab_content);
            }
          };
        }(this)
      );
  }

  return SellerAttachmentsController;
}();

module.exports = SellerAttachmentsController;
