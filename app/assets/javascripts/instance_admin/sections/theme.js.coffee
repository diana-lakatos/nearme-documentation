class @InstanceAdmin.ThemeController

  constructor: (@form) ->
    @resetLinks = @form.find('a[data-reset]')
    @bindEvents()

  bindEvents: ->
    @resetLinks.on 'click', (event) =>
      input = @form.find("input[data-color=#{$(event.target).data('reset')}]")
      if !input.prop('disabled')
        input.val(input.data('default'))
      event.preventDefault()
