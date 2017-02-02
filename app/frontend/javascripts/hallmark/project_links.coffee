module.exports = class ProjectLinks
  constructor: (el) ->
    @wrapper = $(el)
    @initEvents()

  initEvents: ->
    @wrapper.on 'click', '[data-link-edit]', (e) =>
      @enableEditForm $(e.target).closest('.link')

    @wrapper.on 'click', '[data-link-remove]', (e) =>
      @hideOnRemove $(e.target).closest('.link')

    @wrapper.on 'change', 'input[type=file]', (e) =>
      @updateUploadLabel $(e.target).closest('.control-group')

    for error_block in @wrapper.find('[data-link-wrapper] .error-block')
      $(error_block).closest('[data-link-wrapper]').find('[data-link-edit]').click()



  enableEditForm: (link) ->
    link.find('.media-group_link-form').show()
    link.find('[data-link-edit]').hide()

  hideOnRemove: (link) ->
    link.fadeOut()

  trimFileName: (str) ->
    str.replace('C:\\fakepath\\','')

  updateUploadLabel: (control_group) ->
    file_name = @trimFileName(control_group.find('[type="file"]').val())

    control_group.find('label').html file_name
