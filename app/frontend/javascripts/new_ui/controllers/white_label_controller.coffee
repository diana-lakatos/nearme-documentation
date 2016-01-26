module.exports = class WhiteLabelController

  constructor: (form) ->
    @form = $(form)
    @whiteLabelSettingsEnabler = @form.find('input[data-white-label-enabler]')
    @whiteLabelCheckboxes = @form.find('input[data-white-label-settings]')
    @whiteLabelSettingsContainer = @form.find('[data-white-label-settings-container]')

    @resetLinksInit()
    @bindEvents()
    @synchronize()

  resetLinksInit: ->
    @form.find('input[type="color"]').each (index, item)->
      input = $(item)
      button = $('<button type="button" data-reset class="action--remove" title="Reset to default">Reset</button>')
      button.data('input', input)
      input.after(button)

  bindEvents: ->
    @whiteLabelSettingsEnabler.on 'change', =>
      @synchronize()

    @form.on 'click', '[data-reset]', (e) =>
      input = $(e.target).closest('[data-reset]').data('input')
      input.val(input.data('default')) unless input.prop('disabled')


  synchronize: =>
    @whiteLabelSettingsContainer.find('input[type=text], input[type=tel], input[type=email], input[type=url], input[type=color], input[type=file]').prop('disabled', !@whiteLabelSettingsEnabler.is(':checked'))
    @whiteLabelCheckboxes.prop('checked', @whiteLabelSettingsEnabler.is(':checked'))
