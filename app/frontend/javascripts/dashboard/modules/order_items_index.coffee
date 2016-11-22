module.exports = class OrderItemsIndex

  constructor : (context = 'body') ->
    @transactableSelect = $(context)
    if @transactableSelect.find('option:selected').length > 0
      $("#transactable_#{@transactableSelect.find('option:selected').val()}").show()
    else
      $('.panel:first').show()
    @bindEvents()

  bindEvents: ->
    @transactableSelect.on 'change', (e)=>
      $('.panel').hide()
      $("#transactable_#{$(e.target).val()}").show()
