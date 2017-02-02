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

  toggleFields: (element) ->
    state = element.data('shipping-type') == 'predefined'
    if state
      @dimensions_template_fields.hide()
      if @dimensions_template_fields.find("input#transactable_dimensions_template_attributes__destroy").length > 0
        @dimensions_template_fields.find("input#transactable_dimensions_template_attributes__destroy").val('1')
    else
      @dimensions_template_fields.removeClass('hidden')
      @dimensions_template_fields.show()
      if @dimensions_template_fields.find("input#transactable_dimensions_template_attributes__destroy").length > 0
        @dimensions_template_fields.find("input#transactable_dimensions_template_attributes__destroy").val('0')

    @template.trigger('toggle.dimensiontemplates', [!state])
