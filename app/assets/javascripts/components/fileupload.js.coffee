class @Fileupload

  @initialize: (scope = $('body')) ->
    $('div[data-fileupload-wrapper]', scope).each (index, element) =>
      new Fileupload($(element))

  constructor : (@fileInputWrapper) ->
    @fileInput = @fileInputWrapper.find('input[type="file"]')
    @photoCollection = new Photo.Collection(@fileInputWrapper.parent())
    @fileInput.fileupload
      url: @fileInputWrapper.data('url')
      paramName: @fileInputWrapper.data('name')
      dataType: 'json'
      dropZone: @fileInputWrapper
      formData: (form) ->
        params = form.clone()
        params.find("input[name=_method]").remove()
        params.serializeArray()
      add: (e, data) =>
        types = /(\.|\/)(gif|jpe?g|png)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          progressBar = @fileInputWrapper.find('div[data-progress-container]:first').clone()
          progressBar.show()
          @fileInputWrapper.append(progressBar)
          data.progressBar = progressBar
          data.submit()
        else
          alert("#{file.name} seems to not be an image - please select gif, jpg, jpeg or png file")
      progress: (e, data) ->
        if data.progressBar
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.progressBar.find('div[data-progress-bar]').css('width', progress + '%')
      done: (e, data) =>
        data.progressBar.remove()
        photoIndex = @photoCollection.add()
        @photoCollection.update(photoIndex, data.result)
