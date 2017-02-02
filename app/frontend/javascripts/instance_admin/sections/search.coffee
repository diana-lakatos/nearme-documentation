module.exports = class InstanceAdminSearchSettings

  constructor: ->
    @bindEvents()

  bindEvents: ->
    $("ul.sortable").sortable({axis: "y", cursor: "move", stop: @updateIndex, opacity: 0.7 })

  updateIndex: (e, ui) ->
    $.ajax
      type: 'PUT'
      url: ui.item.closest('ul').data('update-url')
      data: { transactable_types: $(e.target).sortable("toArray") }
