module.exports = class DefaultImages
  constructor: ->
    @initialize()

  initialize: ->
    @versions = $("[data-photo-uploaders]").data('photo-uploaders')
    @select_photo_uploader = $('select.photo-uploader')
    @select_versions = $('select.photo-uploader-versions')

    @select_photo_uploader.on 'change', =>
      @updateVersions()

    @updateVersions()

  updateVersions: ->
    photo_uploader = @select_photo_uploader.val()
    if photo_uploader
      current_versions = @versions[photo_uploader]
      @select_versions.empty()
      selected_version = @select_versions.data('selected')
      for version in current_versions
        data = current_versions[version]
        if selected_version == version
          @select_versions.append($("<option selected></option>").attr("value", version[1]).text(version[0]))
        else
          @select_versions.append($("<option></option>").attr("value", version[1]).text(version[0]))
      @select_versions.trigger('chosen:updated')

