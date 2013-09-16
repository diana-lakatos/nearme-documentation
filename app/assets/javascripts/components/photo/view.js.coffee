class @Photo.View

  constructor: ->
    @inputTemplate = $('#photo-item-input-template')

  create: ->
    @photo = $('<div class="photo-item"></div>')
    @photo.html('<div class="thumbnail-processing"><div class="loading-icon"></div><div class="loading-text">Processing...</div></div>')
    @photo

  update: (data) ->
    @data = @normalizeData(data)
    this

  singlePhotoHtml: ->
    deleteLink = $('<a data-url="' + @data.destroy_url + '" class="badge delete-photo delete-photo-thumb photo-action">Delete</a>')
    cropLink = $('<a href="' + @data.resize_url + '" rel="modal"  data-id="photo-' + @data.id + '" class="badge resize-photo photo-action">Rotate & Crop</a>')
    @photo.html("<img src='#{@data.url}' width='#{@data.thumbnail_dimensions.width}' height='#{@data.thumbnail_dimensions.height}'>")
    @photo.append(deleteLink)
    @photo.append(cropLink)

  multiplePhotoHtml: (position) ->
    @singlePhotoHtml()
    @photo.append($('<span>').addClass('photo-position badge badge-inverse').text(position))
    input = $("<input type='text'>").attr('name', @inputTemplate.attr('name')).attr('placeholder', @inputTemplate.attr('placeholder'))
    name_prefix = input.attr('name') + '[' + @data.id + ']'
    input.attr('name', name_prefix + '[caption]')
    @photo.append(input)
    hidden = $('<input type="hidden">')
    hidden_position = hidden.clone().attr('name', "#{name_prefix}[position]").val(position).addClass('photo-position-input')
    @photo.attr('id', "photo-#{@data.id}")
    @photo.append(hidden_position)
    hidden_id = hidden.clone().attr('name', "#{name_prefix}[id]").val(@data.id)
    @photo.append(hidden_id)
    hidden_content_id = hidden.clone().attr('name', "#{name_prefix}[content_id]").val(@data.content_id)
    @photo.append(hidden_content_id)

  normalizeData: (data) ->
    result = jQuery.parseJSON(data)
    if !result
      result = jQuery.parseJSON($('pre', data).text())
    result
