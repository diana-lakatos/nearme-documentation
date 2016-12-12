module.exports = class PhotoView

  constructor: ->
    @inputTemplate = $('#photo-item-input-template')

  create: ->
    @photo = $('<div class="photo-item"></div>')
    @photo.html('<div class="thumbnail-processing"><div class="loading-icon"></div><div class="loading-text">Processing...</div></div>')
    @photo

  update: (data) ->
    @data = @normalizeData(data)
    this

  resize: ->
    row_number = @photo.closest(".uploaded").data('row')
    if row_number
      max_height = Math.max.apply(Math, ($(".uploaded[data-row=#{row_number}]").map((i, item) ->
        photo_item = $(item).find('.photo-item')
        if photo_item.height() > 0
          photo_item.height() + 30
        else
          0
      )))
      if max_height > 0
        $(".uploaded[data-row=#{row_number}]").height("#{max_height}px")
      else
        $(".uploaded[data-row=#{row_number}]").height("auto")

  singlePhotoHtml: ->
    actions = $('<div class="media-actions"></div>')

    cropLink = $('<button type="button" class="button-a small action--edit" data-resize-photo data-modal title="Rotate & Crop"><span class="intelicon-edit"></span></button>')
    cropLink.attr('data-href', @data.resize_url)
    cropLink.attr('data-id', @data.id)
    actions.append(cropLink)

    deleteLink = $('<button class="button-a small danger action--remove" type="button" data-delete-photo title="Delete photo"><span class="intelicon-trash-outlined"></span></button>')
    deleteLink.attr('data-url', @data.destroy_url)
    actions.append(deleteLink)

    # @photo.html("<img src='#{@data.url}' width='#{@data.thumbnail_dimensions.width}' height='#{@data.thumbnail_dimensions.height}'>")
    @photo.html("<img src='#{@data.url}'>")
    actions.appendTo(@photo)

  coverPhotoHtml: ->
    @singlePhotoHtml()
    modelName = @inputTemplate.attr('name')
    @photo.append($('<input>', { type: 'hidden', name: modelName + '[photo_ids][]', value: @data.id }))
    @photo.append($('<input>', { type: 'hidden', name: modelName + '[cover_photo_attributes][id]', value: @data.id }))
    @photo.append($('<input>', { type: 'hidden', name: modelName + '[cover_photo_attributes][photo_role]', value: 'cover' }))

  multiplePhotoHtml: (position) ->
    @singlePhotoHtml()
    input = $("<input type='text'>").attr('name', @inputTemplate.attr('name')).attr('placeholder', @inputTemplate.attr('placeholder')).data('association-name', @inputTemplate.data('association-name'))
    listing_name_prefix = input.attr('name')
    if !input.data('association-name') || input.data('association-name').length == 0
      association_name_singular = 'photo'
    else
      association_name_singular = input.data('association-name')
    association_name_plural = association_name_singular + 's'

    name_prefix = listing_name_prefix + "[#{association_name_plural}_attributes][" + @data.id + ']'
    if !@inputTemplate.data('no-caption')
      input.attr('name', name_prefix + '[caption]')
      @photo.append(input)
    hidden = $('<input type="hidden">')
    hidden_position = hidden.clone().attr('name', "#{name_prefix}[position]").val(position).addClass('photo-position-input')
    @photo.attr('id', "photo-#{@data.id}")
    @photo.append(hidden_position)
    hidden_id = hidden.clone().attr('name', "#{name_prefix}[id]").val(@data.id)
    @photo.append(hidden_id)
    hidden_id = hidden.clone().attr('name', "#{listing_name_prefix}[#{association_name_singular}_ids][]").val(@data.id)
    @photo.append(hidden_id)
    hidden_listing_id = hidden.clone().attr('name', "#{name_prefix}[transactable_id]").val(@data.transactable_id)
    @photo.append(hidden_listing_id)

  normalizeData: (data) ->
    if typeof(data) is 'object'
      data
    else
      result = jQuery.parseJSON(data)
      if !result
        result = jQuery.parseJSON($('pre', data).text())
      result
