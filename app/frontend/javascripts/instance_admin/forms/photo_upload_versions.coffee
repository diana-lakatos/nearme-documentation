module.exports = class PhotoUploadVersions
  constructor: ->
    @initialize()

  initialize: ->
    @versions = $("[data-photo-uploader-versions]").data('photo-uploader-versions')
    @select_photo_uploader = $('select.photo_uploader')
    @select_versions = $('select.uploader_versions')

    @select_photo_uploader.on 'change', =>
      @updateVersions()

    @updateVersions()

  updateVersions: ->
    photo_uploader = @select_photo_uploader.val()
    current_versions = @versions[photo_uploader]
    @select_versions.empty()
    selected_version = @select_versions.data('selected')
    for version in Object.keys(current_versions)
      data = current_versions[version]
      default_text = " (default: " + data["width"] + "x" + data["height"] + " with " + data["transform"] + ")"
      if selected_version == version
        @select_versions.append($("<option selected></option>").attr("value", version).text(version + default_text))
      else
        @select_versions.append($("<option></option>").attr("value", version).text(version + default_text))
    @select_versions.trigger('chosen:updated')

