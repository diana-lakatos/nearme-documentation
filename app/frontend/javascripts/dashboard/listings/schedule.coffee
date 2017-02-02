module.exports = class Schedule
  constructor: (el) ->
    @container = $(el)
    @bindEvents()
    @initModeContainers(@container)

  initModeContainers: (context) ->
    $(context).find('[data-pricing-run-mode]').each (index, item) =>
      container = $(item)
      mode = container.find('[data-pricing-run-mode-selector]').val()
      @setMode(container, mode)

  bindEvents: ->
    # run mode selector changed
    @container.on 'change', '[data-pricing-run-mode-selector]', (e) =>
      container = $(e.target).closest('[data-pricing-run-mode]')
      mode = $(e.target).closest('select').val()
      @setMode(container, mode)

    # add single time field
    @container.on 'click', '[data-add-datetime]', (e) =>
      # control-group selector is a legacy selector for UI prior to 2015-12.
      # It should be removed after instance admin has been updated to newer version
      template = $(e.target).closest('.form-group, .control-group').find('.removable-field:last')
      anchor = $(e.target).closest('.add-entry')
      @addTime(template, anchor)

    # remove single time field
    @container.on 'click', '[data-remove-datetime]', (e) =>
      field = $(e.target).closest('.removable-field')
      @removeTime(field)

    @container.on 'cocoon:after-insert', (e, insertedItem) =>
      @initializeNewRow(insertedItem)



  setMode: (container, mode) ->
    @modes = container.find('.run-mode')
    @modes.addClass('hidden').attr('aria-hidden', true)
    return unless mode
    @modes.filter('.' + mode).removeClass('hidden').removeAttr('aria-hidden')

  addTime: (template, anchor) ->
    field = $(template).clone(false)
    input = field.find('input')
    input.val('')
    input.attr('name', anchor.data('input-name'))
    anchor.before(field)
    $('html').trigger('datepickers.init.forms', [field])
    $('html').trigger('timepickers.init.forms', [field])

  removeTime: (field) ->
    # control-group selector is a legacy selector for UI prior to 2015-12.
    # It should be removed after instance admin has been updated to newer version

    if field.closest('.form-group, .control-group').find('.removable-field').length < 2
      return alert 'You cannot remove the only time field'
    field.remove()

  initializeNewRow: (insertedItem) =>
    @initModeContainers(insertedItem)
    $('html').trigger('datepickers.init.forms', [insertedItem])
    $('html').trigger('timepickers.init.forms', [insertedItem])
    $('html').trigger('selects.init.forms', [insertedItem])
