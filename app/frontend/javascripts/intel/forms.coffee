module.exports = class Forms
  constructor: ()->

  # updates placeholder class on selects
  @placeholders: ()->
    $('select').on('change.placeholder', ->
      $(this).toggleClass 'placeholder', !$(this).val()
    ).triggerHandler 'change.placeholder'


  # zooms out to full page once you leave input control
  @blurZoomOut: ()->
    viewport = $('meta[name=viewport]')
    $('input, textarea, select').on 'blur', (event) ->
      event.preventDefault()
      viewport.attr 'content', 'width=device-width, initial-scale=1.0, maximum-scale=1'
      setTimeout (->
        viewport.attr 'content', 'width=device-width, initial-scale=1.0'
      ), 50

  # placeholders and checking empty on file inputs
  @fileInputs: ()->
    inputs = $('.file-a input')
    inputs.on 'change', ()->
      $input = $(this)
      value = $input.val()
      $input.parent().toggleClass 'is-empty', value == ''

      value = $input.attr('placeholder') if value == ''

      $input.next('span').html value

    inputs.each ->
      $(this).parent().toggleClass 'is-empty', $(this).val() == ''
      $(this).after('<span/>').triggerHandler 'change'
      return

  @linkImages: ()->
    inputs = $('.links-group .control-group.file input')

    inputs.each ()->
      $(this).data('empty-label', $(this).attr('data-upload-label'))

    trimFileName = (str)->
      str.replace('C:\\fakepath\\','')


    inputs.on 'change', ()->
      label = if $(this).val() then trimFileName($(this).val()) else $(this).data('empty-label')
      $(this).closest('.control-group.file').attr('data-upload-label', label)

  # selectize plugin
  @selectize: ()->
    return unless $.fn.selectize and !Modernizr.touch

    $('select.selectize').each (index, el) ->
      $select = $(this)
      $select.selectize
        plugins: [ 'remove_button' ]
        hideSelected: false
        closeAfterSelect: !$select.is('[multiple]')

      $select.on 'change', =>
        if `$select.val() == 0`
          $select.val('')

  @initialize: ()->
    @placeholders()
    @blurZoomOut()
    @fileInputs()
    @linkImages()
    @selectize()
