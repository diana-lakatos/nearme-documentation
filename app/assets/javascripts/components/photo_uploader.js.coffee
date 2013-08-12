class @PhotoUploader

  @initialize: (scope = $('body')) ->
    $('.fileupload', scope).each (index, element) =>
      new PhotoUploader($(element))
    @enableInputFieldInFirefox()

  @enableInputFieldInFirefox: ->
    if $.browser.mozilla
      $('.fileupload').on 'click', 'label', (e) ->
        if e.currentTarget == this && e.target.nodeName != 'INPUT'
          $(this.control).click()

  constructor : (container) ->
    @container = container
    @sortable = container.find('#sortable-photos')
    @fileInput = container.find('.browse-file').eq(0)
    @photos = container.find('.photo-item a')
    @uploaded = container.find('.uploaded').eq(0)

    @init()
  
  init : ->
    @listenToDeletePhoto()
    @initializeFileUploader()
    @initializeSortable()

  listenToDeletePhoto: ->
    self = this
    @uploaded.on 'click', '.delete-photo',  ->
      url = $(this).attr("data-url")
      link = $(this)
      if confirm("Are you sure you want to delete this Photo?")
        $.post link.attr("data-url"), { _method: 'delete' }, ->
          link.closest(".photo-item").remove()
          self.reorderSortableList()
      return false

  initializeFileUploader : =>
    @fileInput.fileupload {
        add: (e, data) =>
          @add(data)
        ,
        done:  (e, data) =>
          data.result = @parseResult(data)
          @done(data)
          @reorderSortableList()
        ,
        progress: (e, data) =>
          data.result = @parseResult(data)
          @progress(data)
    }

  initializeSortable: ->
    @sortable.sortable
      stop: =>
        @reorderSortableList()
      placeholder: 'photo-placeholder',
    @sortable.disableSelection();

  add: (data) =>
    @setPhotoItem(@getUniqueString(data))
    data.submit()

  parseResult: (data) ->
    if $.browser.msie && parseInt($.browser.version) < 10
      result_to_parse = $('pre', data.result).text()
    else
      result_to_parse = data.result
    jQuery.parseJSON(result_to_parse)

  done: (data) =>
    if @singlePhotoExists() && !@multiplePhoto()
      @replaceExistingImg(data)
    else
      @addImg(data)
    @fileInput = @container.find('.browse-file').eq(0)
    @initializeFileUploader()

  progress: (data) =>
    progress = parseInt(data.loaded / data.total * 100, 10)
    @photoItem = @getPhotoItem(@getUniqueString(data))
    @progressBar = @photoItem.find('.progress .bar').eq(0)
    @progressBar.css('width', progress + '%')
    if progress == 100
      @progressBar.css('width', 0 + '%')
      @photoItem.html(@getLoadingElement())
      @photoItem.removeClass('hidden')

  getLoadingElement: (text = 'Processing...' ) ->
    '<div class="thumbnail-processing"><div class="loading-icon"></div><div class="loading-text">' + text + '</div></div>'

  getPhotoItem: (filename) =>
    $('.photo-item[data-filename="' + filename.hashCode() + '"]:last')

  setPhotoItem: (filename) =>
    if @multiplePhoto()
      @photoItem = $('<div class="photo-item hidden"></div>')
      @sortable.append(@photoItem)
    else
      if @singlePhotoExists()
        @photoItem = @uploaded.find('.photo-item').eq(0)
      else
        @photoItem = $('<div class="photo-item"></div>')
        @uploaded.append(@photoItem)
    @photoItem.attr("data-filename", filename.hashCode())
    @addProgressBar(filename)

  addProgressBar: (filename) ->
    @photoItem = @getPhotoItem(filename)
    if @photoItem.find('.progress').length == 0
      if $.browser.msie && parseInt($.browser.version) < 10
        @photoItem.append(@getLoadingElement('Uploading...'))
        @photoItem.find('.loading-icon').removeClass('loading-icon').addClass('animated-progress-bar')
      else
        @photoItem.append('<div class="progress"><div class="bar"></div></div>')

  multiplePhoto: =>
    @sortable.length > 0

  singlePhotoExists: =>
    @uploaded.find('img').length > 0

  replaceExistingImg: (data) =>
    @uploaded.find('img').attr('src', data.result.url)

  addImg: (data) =>
    href = $('<a data-url="' + data.result.destroy_url + '" class="badge badge-inverse delete-photo delete-photo-thumb">Delete</span></a>')
    @photoItem = @getPhotoItem(@getUniqueString(data))
    @photoItem.html('<img src="' + data.result.url + '">')
    @photoItem.append(href)
    if @multiplePhoto()
      @photoItem.append($('<span>').addClass('photo-position badge badge-inverse').text(@getLastPosition()))
      hidden = $('<input>').attr('type', 'hidden')
      hidden_position = hidden.clone().attr('name', "#{name_prefix}[position]").val(@getLastPosition()).addClass('photo-position-input')
      @photoItem.attr('id', "photo-#{data.result.id}")
      @photoItem.append(hidden_position)
      input = @container.find('#photo-item-input-template').clone()
      input.attr('disabled', false)
      input.attr('type', 'text')
      last_input = @container.find('input[data-number]').eq(-1)
      data_number = parseInt(last_input.attr('data-number')) + 1
      input.attr('data-number', data_number)
      name_prefix = input.attr('name') + '[' + data_number + ']'
      input.attr('name', name_prefix + '[caption]')
      @photoItem.append(input)
      hidden_id = hidden.clone().attr('name', "#{name_prefix}[id]").val(data.result.id)
      @photoItem.append(hidden_id)

  getLastPosition: ->
    @sortable.find('.photo-item:not(.hidden)').length

  reorderSortableList: ->
    i = 0
    for index, el of @sortable.sortable('toArray')
      if el != '' and $("##{el}.photo-item:not(.hidden)").length > 0
        $("##{el}").find('.photo-position-input').val(i)
        $("##{el}").find('.photo-position').text(parseInt(i) + 1)
        i++


  getUniqueString: (data) ->
    if((navigator.platform.indexOf("iPhone") != -1) || (navigator.platform.indexOf("iPod") != -1))
      data.files[0].lastModifiedDate.toString()
    else
      data.files[0].name

