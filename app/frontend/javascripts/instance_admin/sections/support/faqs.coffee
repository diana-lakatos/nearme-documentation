module.exports = class InstanceAdminFaqsController

  constructor: (@container) ->
    @bindEvents()

  bindEvents: =>
    @container.find("tbody").sortable
      stop: @updateIndex
      helper: @fixTableRowWidths

  updateIndex: (e, ui) =>
    $.ajax
      type: 'PUT'
      url: ui.item.find('td a').last().attr('href')
      dataType: 'JSON'
      data: { support_faq: { position_position: @container.find('tbody tr').index(ui.item) } }

  fixTableRowWidths: (e, tr) ->
    originals = tr.children()
    helper = tr.clone()
    helper.children().each (index) ->
      $(this).width(originals.eq(index).width())
    helper
