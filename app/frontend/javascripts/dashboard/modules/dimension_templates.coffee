require 'selectize/dist/js/selectize'

module.exports = class DimensionTemplates
  constructor: (container, units) ->
    @container = $(container)
    @units = units
    @dimensions_templates_select = @container.find('[data-shipping-dimensions-templates-select]')
    @unit_of_measure = @container.find('[data-shipping-unit-of-measure]')
    @dimension_fields = @prepareFields('shipping-dimension')
    @unit_fields = @prepareFields('shipping-dimension-unit')
    @addTemplateTrigger = @container.find('[data-add-template-trigger]')
    @state = true

    @bindEvents()
    @initialize()

  bindEvents: ->
    @dimensions_templates_select.on 'change', =>
      @updateDimensionsFieldsFromTemplates()

    @container.on 'toggle.dimensiontemplates', (e, state) =>
      @toggle(state)

    @unit_of_measure.filter('select').on 'change', @updateUnits

    @addTemplateTrigger.on 'click', (e) =>
      e.preventDefault()
      return false unless @state

      ajaxOptions = { url: $(e.target).attr('href') }
      $(document).trigger('load:dialog.nearme', [ajaxOptions])


  prepareFields: (attr) ->
    out = {}
    @container.find("[data-#{attr}]").each ->
      out[$(@).data(attr)] = $(@)

    return out

  initialize: ->
    return unless @dimensions_templates_select.length > 0
    interval = window.setInterval(=>
      if @dimensions_templates_select.get(0).selectize
        window.clearInterval(interval)
        @setDefaultOptionAsSelected()
        @updateDimensionsFieldsFromTemplates()
    , 50)

  toggle: (state) ->
    @state = state
    @container.toggleClass('form-section-disabled', !state)
    @container.find('input, textarea').attr('readonly', !state)
    @container.find('select').each ->
      if state then this.selectize.enable() else this.selectize.disable()

  updateUnits: =>
    unit_type = @unit_of_measure.val()

    for item in ['weight', 'height', 'width', 'depth']
      unit_selectize = @unit_fields[item].get(0).selectize
      unit_selectize.clearOptions()
      new_elements = @getOptionsTextByUnitType(unit_type, item)
      for new_element in new_elements
        unit_selectize.addOption({ value: new_element, text: new_element })

      unit_selectize.setValue(new_elements[0])

  setDefaultOptionAsSelected: ->
    return if @container.parents('form').find('input[name="_method"]').val() == 'put' || $('#product_errors_present').length > 0
    for key in Object.keys(@dimensions_templates_select.get(0).selectize.options)
      option = @dimensions_templates_select.get(0).selectize.options[key]
      if option.template.use_as_default
        @dimensions_templates_select.get(0).selectize.setValue(option.value)

  updateDimensionsFieldsFromTemplates: ->
    current = @dimensions_templates_select.get(0).selectize.items[0]
    data_options = @dimensions_templates_select.get(0).selectize.options[current].template if current

    return @updateDimensionTemplateSelect() unless data_options

    @unit_of_measure.val(data_options['unit_of_measure'])

    for item in ['weight', 'height', 'width', 'depth']

      unit_selectize = @unit_fields[item].get(0).selectize
      unit_selectize.clearOptions()
      new_elements = @getOptionsTextByUnitType(data_options['unit_of_measure'], item)
      @dimension_fields[item].val data_options[item]

      for new_element in new_elements
        unit_selectize.addOption({ value: new_element, text: new_element })
        unit_selectize.setValue(new_element) if data_options[item + '_unit'] == new_element

  updateDimensionTemplateSelect: ->
    current = null
    $.each @dimensions_templates_select.get(0).selectize.options, (index, option) =>
      template = option.template
      return if @unit_of_measure.val() isnt template['unit_of_measure']

      for item in ['weight', 'height', 'width', 'depth']
        return if @dimension_fields[item].val() isnt template[item]

      current = index

    @dimensions_templates_select.get(0).selectize.setValue(current) if current isnt null

  getOptionsTextByUnitType: (unit_type, unit_name) ->
    result = []

    if $.inArray(unit_name, ['width', 'height', 'depth']) >= 0
      unit_name = 'length'

    for item in @units[unit_type][unit_name]
      result.push item

    return result
