module.exports = class DimensionsTemplateController
  constructor: (container) ->
    @container = $(container)
    @dimensions_template_fields = $('.dimensions_template')
    @template = $('[data-dimension-templates]')
    @shipping_profile = @container.find('[data-shipping-type]')
    @toggleFields(@shipping_profile.filter(':checked'))
    @bindEvents()

  bindEvents: ->
    @shipping_profile.on 'change', (e) =>
      @toggleFields($(e.target))

  toggleFields: (element)->
    state = element.data('shipping-type') == 'predefined'
    if state
      @dimensions_template_fields.hide()
    else
      @dimensions_template_fields.removeClass('hidden')
      @dimensions_template_fields.show()
    @template.trigger('toggle.dimensiontemplates', [!state])
