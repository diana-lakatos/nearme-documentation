class @FormComponents

  constructor: (@sortable_container, @transactable_type_id) ->
    @bindEvents()

  bindEvents: ->
    $(@sortable_container).sortable(axis: "y", cursor: "move", update: (event, ui) =>
      id = ui.item.data('id')
      index = ui.item.index()
      $.ajax(data: { '_method': 'patch', 'rank_position': index}, type: 'POST', url: "/instance_admin/manage/transactable_types/#{@transactable_type_id}/form_components/" + id + "/update_rank", complete: ->
        ui.item.find('.panel-heading').effect("highlight", {}, 2000)
      )
    )


