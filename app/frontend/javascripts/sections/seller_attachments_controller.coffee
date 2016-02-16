module.exports = class SellerAttachmentsController
  constructor: (@container, @seller_attachment_options = {}) ->
    @path = @seller_attachment_options.path
    @tab_header = @container.find('ul[data-tab-header]')
    @tab_content = @container.find('div[data-tab-content]')
    @seller_attachable =  @seller_attachment_options.seller_attachable
    $.get(@path, {seller_attachable_type: @seller_attachable.type, seller_attachable_id: @seller_attachable.id }).success( (response) =>
      if response.tab_header != ''
        @tab_header.append(response.tab_header)
        tab_content = $(response.tab_content)
        @tab_content.append(tab_content)
    )
