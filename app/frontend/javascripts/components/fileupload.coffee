require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.iframe-transport.js')
require('imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.fileupload.js')

CkfileCollection = require('./ckfile/collection')
PhotoCollection = require('./photo/collection')

module.exports = class Fileupload

  constructor: (fileInputWrapper) ->
    @fileInputWrapper = $(fileInputWrapper)
    @fileInput = @fileInputWrapper.find('input[type="file"]')
    @file_types = @fileInput.attr('data-file-types')
    @upload_type = @fileInput.attr('data-upload-type')
    @files_container = @fileInput.attr('data-files-container')
    @wrong_file_message = @fileInput.attr('data-wrong-file-message')
    @append_result = if @fileInput.attr('data-append-result') == '1' then true else false
    @preventEarlySubmission()
    @processing = 0

    if @upload_type == 'ckfile'
      @fileCollection = new CkfileCollection($(@files_container))
      @dataType = 'html'
    else if @upload_type == 'attachment'
      @dataType = 'html'
    else
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
          types = new RegExp(@file_types, 'i')
        else
          types = /(\.|\/)(gif|jpe?g|png|ico)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          progressBar = @fileInputWrapper.find('div[data-progress-container]:first').clone()
          progressBar.find('span[data-filename]').text(file.name)
          progressBar.show()
          @fileInputWrapper.append(progressBar)
          data.progressBar = progressBar
          data.submit()
        else
          if @wrong_file_message && @wrong_file_message != ''
            alert("#{file.name} " + @wrong_file_message)
          else
            alert("#{file.name} seems to not be an image - please select gif, jpg, jpeg or png file")
      progress: (e, data) ->
        if data.progressBar
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.progressBar.find('div[data-progress-bar]').css('width', progress + '%')
      done: (e, data) =>
        if @upload_type == 'attachment'
          @fileInputWrapper.parent().find('[data-uploaded]').html(data.result)
        else
          fileIndex = @fileCollection.add()
          @fileCollection.update(fileIndex, data.result, @append_result)

      fail: (e, data) ->
        window.alert('Unable to process this request, please try again.')
        window.Raygun.send(data.errorThrown, data.textStatus) if window.Raygun

      always: (e, data) =>
        @processing -= 1
        data.progressBar.remove()

  preventEarlySubmission: ->
    @fileInputWrapper.parents('form').on 'submit', =>
      if @processing > 0
        alert 'Please wait until all files are uploaded before submitting.'
        false
