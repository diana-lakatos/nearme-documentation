class @Multiselect
  constructor: (element) ->
    @element = $(element)
    @element.data('multiselect', @)

    @collapsedContainer = @element.find('.collapsed')
    @expandedContainer  = @element.find('.expanded')
    @expandedSummary    = @expandedContainer.find('.summary')

    # Setup initial state
    @updateValues()
    @bindEvents()

  bindEvents: ->
    @expandedContainer.on 'click', 'input[type="checkbox"]', (event) =>
      @itemSelectionChanged($(event.target))

    @collapsedContainer.on 'click', =>
      @open()

    @expandedSummary.on 'click', =>
      @close()

    $('body').on 'click', (event) =>
      # Close if we've clicked on an element that isn't a descendant of the multiselect
      @close() if @isOpen and $(event.target).closest(@element).length == 0


  itemSelectionChanged: (item) ->
    $item = $(item)
    $item.closest('.item').toggleClass('checked', $item.is(':checked'))
    @updateCount()

  open: ->
    @collapsedContainer.hide()
    @expandedContainer.show().toggleClass('long', @items.length > 8)
    @isOpen = true

  items: ->
    @expandedContainer.find('input[type="checkbox"]:checked')

  close: ->
    @expandedContainer.hide()
    @collapsedContainer.show()
    @isOpen = false

  updateValues: ->
    selected = @expandedContainer.find('input[type="checkbox"]:checked')
    selected.closest('.item').addClass('checked')
    @updateCount(selected.length)

  updateCount: (newCount = @items().length) ->
    text = if newCount == 0
      "None selected"
    else
      "#{newCount} selected"

    @collapsedContainer.text(text)
    @expandedSummary.text(text)


  @initialize: (scope) ->
    $('.multiselect', scope).each ->
      new Multiselect(@)

