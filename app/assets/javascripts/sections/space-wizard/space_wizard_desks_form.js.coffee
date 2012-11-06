class @SpaceWizardDesksForm
  constructor: (@container) ->
    @desksContainer = @container.find('.listings')
    @template = @container.find('.fieldset.template')

    # Disable the template fields so they don't submit
    @template.find('input, textarea, select').prop('disabled', true)

    # Initialize each fieldset already rendered
    @container.find('.fieldset:not(.template)').each (i, fieldset) =>
      new Fieldset(this, $(fieldset))

    @bindEvents()

  addDeskFields: ->
    fieldset = Fieldset.fromTemplate(this, @template)
    fieldset.appendTo(@desksContainer)
    fieldset.setNumber(@desksContainer.find('.fieldset:not(.template)').length)

  deskRemoved: ->
    @desksContainer.find('.fieldset:not(.template)').each (i, fields) =>
      $(fields).data('fieldset').setNumber(i+1)

  bindEvents: ->
    @container.on 'click', '[data-behavior*=addDesk]', (event) =>
      event.preventDefault()
      @addDeskFields()
      false

  class Fieldset
    @fromTemplate: (form, template) ->
      # A unique ID for the new fieldset
      id = new Date().getTime()
      fields = template.clone()
      fields.removeClass('template').hide()
      inputs = fields.find('input, textarea, select')
      inputs.prop('disabled', false)

      # Need to replace field names to include the unique ID of the new fieldset
      inputs.each (i, input) =>
        input = $(input)
        name = input.prop('name').replace(/attributes\]\[\d\]/, "attributes][#{id}]")
        input.prop('name', name)

      # Return the new fieldset
      new Fieldset(form, fields)

    constructor: (@form, @container) ->
      @container.data('fieldset', this)
      @priceInput = @container.find('input[name*=price]')
      @freeCheckbox = @container.find('input[type=checkbox][name*=free]')
      @bindEvents()

    appendTo: (container) ->
      container.append(@container)
      @container.fadeIn('fast')

    setNumber: (i) ->
      @container.find('.legend span').text(i)

    bindEvents: ->
      @container.on 'keypress', 'input[name*=price]', =>
        @priceChanged()

      @container.on 'blur', 'input[name*=price]', =>
        @priceChanged()

      @container.on 'change', 'input[type=checkbox][name*=free]', =>
        @freeChanged()

      @container.on 'click', '.close-button', (e) =>
        e.preventDefault()
        @container.fadeOut 'fast', =>
          @container.remove()
          @form.deskRemoved()
        false

    freeChanged: ->
      if @freeCheckbox.prop('checked')
        @priceInput.val('0.00')
      else
        @priceInput.focus().val('')

    priceChanged: ->
      price = @priceInput.val()
      checkFree = price == '' or price == '0' or parseFloat(price) == 0
      @freeCheckbox.prop('checked', checkFree)




