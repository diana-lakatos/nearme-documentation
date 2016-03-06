module.exports = class FormComponents

  constructor: (@sortable_container) ->
    @initial_path = @sortable_container.data('initial-path')
    @bindEvents()

  bindEvents: ->
    $(@sortable_container).sortable({
      axis: "y",
      cursor: "move",
      update: (event, ui) =>
        id = ui.item.data('id')
        index = ui.item.index()
        $.ajax({
          data: {
            '_method': 'patch',
            'rank_position': index
          },
          type: 'POST',
          dataType: 'json',
          url: @initial_path + "/#{id}/update_rank",
          complete: ->
            ui.item.find('.panel-heading').effect("highlight", {}, 2000)
        })
    })


