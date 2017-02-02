require('bootstrap-colorpicker/dist/js/bootstrap-colorpicker')

module.exports = class InstanceAdminThemeController

  constructor: (@form) ->
    @resetLinks = @form.find('a[data-reset]')
    @bindEvents()

    $('.color-picker-text-field').colorpicker('format': 'hex').on 'changeColor.colorpicker', (event) ->
      $(event.target).parent().find('.color-picker-color').css 'background-color', event.color.toHex()
      return

    $('.color-picker-color').click ->
      $(this).parent().find('.color-picker-text-field').colorpicker('show')

  bindEvents: ->
    @resetLinks.on 'click', (event) =>
      input = @form.find("input[data-color-name=#{$(event.target).data('reset')}]")
      defaultColor = input.data('default')
      if !input.prop('disabled') and defaultColor
        input.val(defaultColor)
        $(input).colorpicker('setValue', defaultColor)
      event.preventDefault()
