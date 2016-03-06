require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.iframe-transport.js');
require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.fileupload.js');

PhotoCollection = require('./photo/collection')

module.exports = class Fileupload


  constructor : (fileInputWrapper) ->
    @fileInputWrapper = $(fileInputWrapper)
    @fileInput = @fileInputWrapper.find('input[type="file"]')
    @file_types = @fileInput.attr('data-file-types')
    @upload_type = @fileInput.attr('data-upload-type')
    @files_container = @fileInput.attr('data-files-container')
    @wrong_file_message = @fileInput.attr('data-wrong-file-message')
    @label = @fileInputWrapper.find('label')
    @preventEarlySubmission()
    @processing = 0

    @fileCollection = new PhotoCollection(@fileInputWrapper.parent())
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
        @processing += 1
        if @file_types && @file_types != ''
          types = new RegExp(@file_types, 'i');
        else
          types = /(\.|\/)(gif|jpe?g|png)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          @updateLabel()
          data.submit()
        else
          if @wrong_file_message && @wrong_file_message != ''
            alert("#{file.name} " + @wrong_file_message)
          else
            alert("#{file.name} seems to not be an image - please select gif, jpg, jpeg or png file")
      done: (e, data) =>
        if @upload_type == 'attachment'
          @fileInputWrapper.parent().find('[data-uploaded]').html(data.result)
        else
          fileIndex = @fileCollection.add()
          @fileCollection.update(fileIndex, data.result)

      fail: (e, data) =>
        window.alert('Unable to process this request, please try again.')
        window.Raygun.send(data.errorThrown, data.textStatus) if window.Raygun

      always: (e, data)=>
        @processing -= 1
        @updateLabel()


  updateLabel: ->
    defaultLabel = if @fileInput.is('[multiple]') then 'Add photo' else 'Upload photo'
    switch @processing
      when 0 then text = defaultLabel
      when 1 then text = 'Uploading photo...'
      else text = "Uploading #{@processing} photos..."
    @label.html text
    @label.toggleClass('active', @processing > 0)

  preventEarlySubmission: ->
    @fileInputWrapper.parents('form').on 'submit', =>
      if @processing > 0
        alert 'Please wait until all files are uploaded before submitting.'
        false
