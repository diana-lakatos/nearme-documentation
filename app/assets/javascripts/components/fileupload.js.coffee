class @Fileupload

  @initialize: (scope = $('body')) ->
    $('div[data-fileupload-wrapper]', scope).each (index, element) =>
      new Fileupload($(element))

  constructor : (@fileInputWrapper) ->
    @fileInput = @fileInputWrapper.find('input[type="file"]')
    @file_types = @fileInput.attr('data-file-types')
    @upload_type = @fileInput.attr('data-upload-type')
    @files_container = @fileInput.attr('data-files-container')
    if @upload_type == 'ckfile'
      @fileCollection = new Ckfile.Collection($(@files_container))
      @dataType = 'html'
    else
      @fileCollection = new Photo.Collection(@fileInputWrapper.parent())
      @dataType = 'json'
      
    @fileInput.fileupload
      url: @fileInputWrapper.data('url')
      paramName: @fileInputWrapper.data('name')
      dataType: @dataType
      dropZone: @fileInputWrapper
      formData: (form) ->
        params = form.clone()
        params.find("input[name=_method]").remove()
        params.serializeArray()
      add: (e, data) =>
        if @file_types && @file_types != ''
          types = new RegExp(@file_types, 'i');
        else
          types = /(\.|\/)(gif|jpe?g|png)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          progressBar = @fileInputWrapper.find('div[data-progress-container]:first').clone()
          progressBar.show()
          @fileInputWrapper.append(progressBar)
          data.progressBar = progressBar
          data.submit()
        else
          if @upload_type == 'ckfile'
            alert("#{file.name} does not have an accepted extension. Please select a document or an image.")
          else
            alert("#{file.name} seems to not be an image - please select gif, jpg, jpeg or png file")
      progress: (e, data) ->
        if data.progressBar
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.progressBar.find('div[data-progress-bar]').css('width', progress + '%')
      done: (e, data) =>
        data.progressBar.remove()
        fileIndex = @fileCollection.add()
        @fileCollection.update(fileIndex, data.result)
