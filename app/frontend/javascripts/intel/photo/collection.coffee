ScreenLockLoader = require('../screen_lock_loader')
PhotoView = require('./view')

module.exports = class PhotoCollection

  constructor : (container) ->
    @container = container
    @sortable = container.find('#sortable-photos')
    @uploaded = container.find('.uploaded').eq(0)
    @initial_length = @sortable.find('.photo-item').length
    @position = 1
    @photos = []
    @loader = new ScreenLockLoader => $('.loading')
    @processingPhotos = 0
    @init()

  init: ->
    @listenToDeletePhoto()
    @listenToFormSubmit()
    if @multiplePhoto()
      @initializeSortable()
      @reorderSortableList()

  add: ->
    photo = new PhotoView
    if @multiplePhoto()
      photo.create().appendTo(@sortable)
    else
      if @singlePhotoExists()
        @uploaded.find('.photo-item, .media-section').eq(0).replaceWith(photo.create())
      else
        photo.create().appendTo(@uploaded)
      photo.resize()
    # return index of new element, since push returns current length, we subtract 1
    @photos.push(photo) - 1

  update: (photo_index, data) ->
    photo = @photos[photo_index].update(data)
    if @multiplePhoto()
      photo.multiplePhotoHtml(@initial_length + @position++)
      @reorderSortableList()
    else if @coverPhoto()
      photo.coverPhotoHtml()
    else
      photo.singlePhotoHtml()
      photo.resize()

  initializeSortable: ->
    @sortable.sortable
      stop: =>
        @reorderSortableList()
      placeholder: 'photo-placeholder'
      cancel: 'input'

  multiplePhoto: =>
    @sortable.length > 0

  coverPhoto: =>
    return true if @container.data('role') == 'cover-photo'

  singlePhotoExists: =>
    @uploaded.find('img').length > 0

  listenToDeletePhoto: ->
    @uploaded.on 'click', '.delete-photo, [data-delete-photo]', (e) =>
      @processingPhotos += 1
      link = $(e.target).closest("[data-url]")
      url = link.attr("data-url")
      if confirm("Are you sure you want to delete this Photo?")
        photo = link.closest(".photo-item").html('<div class="thumbnail-processing"><div class="loading-icon"></div><div class="loading-text">Deleting...</div></div>')
        $.post link.attr("data-url"), { _method: 'delete' }, =>
          row_number = photo.closest(".uploaded").data('row')
          photo.remove()
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
          @initial_photo = @initial_photo - 1
          @processingPhotos -= 1
          if @processingPhotos == 0
            @loader.hide()
          if @multiplePhoto()
            @reorderSortableList()
      return false


  listenToFormSubmit: ->
    @container.parents('form').on 'submit', =>
      if @processingPhotos > 0
        @loader.show()
        false


  reorderSortableList: ->
    i = 0
    for index, el of @sortable.sortable('toArray')
      if el != '' and $("##{el}.photo-item").length > 0
        $("##{el}").find('.photo-position-input').val(i)
        $("##{el}").find('.photo-position').text(parseInt(i) + 1)
        i++
