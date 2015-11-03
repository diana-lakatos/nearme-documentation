class @SellerAttachmentAccessLevelSelector
  constructor: (parentContainer) ->
    instance = @
    if !parentContainer
      parentContainer = $(document)

    $(parentContainer).find('select[data-seller-attachment-access-level]').on 'change', ->
      instance.bindAttachmentUpdate($(@), 'access_level')

    $(parentContainer).find('input[data-seller-attachment-title]').on 'blur', ->
      instance.bindAttachmentUpdate($(@), 'title')

  bindAttachmentUpdate: (self, paramKey) ->
    params = {
      url: self.attr('data-seller-attachment-update-url'),
      method: 'PUT',
      'data': {'seller_attachment': {}}
    }
    params['data']['seller_attachment'][paramKey] = self.val()
    $.ajax(params)

