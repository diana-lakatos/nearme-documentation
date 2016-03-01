module.exports = class InstanceAdminPagesController

  constructor: (@container) ->
    # For now we do not want to allow pages sorting
    return

    @bindEvents()

  bindEvents: =>
    @container.find("tbody").sortable
      stop: @updateIndex
      helper: @fixTableRowWidths

  updateIndex: (e, ui) =>
    $.ajax
      type: 'PUT'
      url: ui.item.find('td a').first().attr('href')
      dataType: 'JSON'
      data: { page: { position_position: @container.find('tbody tr').index(ui.item) } }

  fixTableRowWidths: (e, tr) ->
    originals = tr.children()
    helper = tr.clone()
    helper.children().each (index) ->
      $(this).width(originals.eq(index).width())
    helper
