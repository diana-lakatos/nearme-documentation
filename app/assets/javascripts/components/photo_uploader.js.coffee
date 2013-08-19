class @PhotoUploader

  @initialize: (scope = $('body')) ->
    $('.fileupload', scope).each (index, element) =>
      new PhotoUploader($(element))

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
    __insp.push(['tagSession', "first_listing_form_visit"]);

  listenToDeletePhoto: ->
    self = this
    @uploaded.on 'click', '.delete-photo',  ->
      url = $(this).attr("data-url")
      link = $(this)
      if confirm("Are you sure you want to delete this Photo?")
        $.post link.attr("data-url"), { _method: 'delete' }, ->
          link.closest(".photo-item").remove()
          if @multiplePhoto()
            self.reorderSortableList()
      return false

  initializeFileUploader : =>
    @fileInput.fileupload {
        add: (e, data) =>
          # data.context will contain markup for image, that will be accessible in every other method like progress, done
          # to easily update the right container with appriopriate info [ i.e info that uploaded has been finished and inserting image preview]
          if @multiplePhoto()
            data.context = $('<div class="photo-item"></div>').appendTo(@sortable)
          else
            if @singlePhotoExists()
              data.context = @uploaded.find('.photo-item').eq(0)
            else
              data.context = $('<div class="photo-item"></div>').appendTo(@uploaded)
              
          if data.context.find('.progress').length == 0
            if $.browser.msie && parseInt($.browser.version) < 10
              data.context.append(@getLoadingElement('Uploading...'))
              data.context.find('.loading-icon').removeClass('loading-icon').addClass('animated-progress-bar')
            else
              data.context.append(@getLoadingElement("Uploading...<div class='progress'><div class='bar'></div></div>"))
              data.context.find('.loading-icon').css('visibility': 'hidden')
          data.submit()
        ,

        done:  (e, data) =>
          @addImg(data)
          @fileInput = @container.find('.browse-file').eq(0)
          @initializeFileUploader()
          if @multiplePhoto()
            @reorderSortableList()

        ,
        progress: (e, data) =>
          @progress(data)
    }

    @fileInput.on 'click', ->
      __insp.push(['tagSession', "photo_upload_clicked"]);

  initializeSortable: ->
    @sortable.sortable
      stop: =>
        @reorderSortableList()
      placeholder: 'photo-placeholder',
    @sortable.disableSelection()

  progress: (data) =>
    progress = parseInt(data.loaded / data.total * 100, 10)
    @progressBar = data.context.find('.progress .bar').eq(0)
    @progressBar.css('width', progress + '%')
    if progress >= 99
      @progressBar.css('width', 0 + '%')
      data.context.html(@getLoadingElement())

  getLoadingElement: (text = 'Processing...' ) ->
    '<div class="thumbnail-processing"><div class="loading-icon"></div><div class="loading-text">' + text + '</div></div>'

  multiplePhoto: =>
    @sortable.length > 0

  singlePhotoExists: =>
    @uploaded.find('img').length > 0

  replaceExistingImg: (data) =>
    @uploaded.find('img').attr('src', data.result.url)

  addImg: (data) =>
    result = jQuery.parseJSON(data.result)
    if !result
      result = jQuery.parseJSON($('pre', data.result).text())
    data.result = result
    href = $('<a data-url="' + data.result.destroy_url + '" class="badge badge-inverse delete-photo delete-photo-thumb">Delete</span></a>')
    data.context.html('<img src="' + data.result.url + '">')
    data.context.append(href)
    if @multiplePhoto()
      data.context.append($('<span>').addClass('photo-position badge badge-inverse').text(@getLastPosition()))
      hidden = $('<input>').attr('type', 'hidden')
      hidden_position = hidden.clone().attr('name', "#{name_prefix}[position]").val(@getLastPosition()).addClass('photo-position-input')
      data.context.attr('id', "photo-#{data.result.id}")
      data.context.append(hidden_position)
      input = @container.find('#photo-item-input-template').clone()
      input.attr('disabled', false)
      input.attr('type', 'text')
      last_input = @container.find('input[data-number]').eq(-1)
      data_number = parseInt(last_input.attr('data-number')) + 1
      input.attr('data-number', data_number)
      name_prefix = input.attr('name') + '[' + data_number + ']'
      input.attr('name', name_prefix + '[caption]')
      data.context.append(input)
      hidden_id = hidden.clone().attr('name', "#{name_prefix}[id]").val(data.result.id)
      data.context.append(hidden_id)

  getLastPosition: ->
    @sortable.find('.photo-item').length

  reorderSortableList: ->
    i = 0
    for index, el of @sortable.sortable('toArray')
      if el != '' and $("##{el}.photo-item").length > 0
        $("##{el}").find('.photo-position-input').val(i)
        $("##{el}").find('.photo-position').text(parseInt(i) + 1)
        i++
