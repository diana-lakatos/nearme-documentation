module.exports = class DashboardDataUploadController

  constructor: (@container, @statusUrl, @dataUploads) ->
    @monitor()


  monitor: ->
    dataUploadsIds = (key for key, val of @dataUploads)
    if dataUploadsIds.length > 0
      $.get(@statusUrl, { 'ids[]': dataUploadsIds }).done( (data) =>
        for data_upload in data
          @refreshDataUpload(data_upload)
        setTimeout ( =>
          @monitor()
        ), 3000
      )

  refreshDataUpload: (data_upload) ->
    id = data_upload[0]
    state = data_upload[1]
    progress = data_upload[2]
    if state != @dataUploads[id].state
      @dataUploads[id].state = state
      @updateDataUploadRow(id)
      if state != 'importing' && state != 'processing'
        delete @dataUploads[id]
    else if state == 'importing'
      @updateDataUploadProgress(id, progress)

  updateDataUploadRow: (id) ->
    $.get(@dataUploads[id].url).done( (data) =>
      dataUploadRow = @domForDataUploadId(id)
      dataUploadRow.replaceWith(data)
      @domForDataUploadId(id).effect("highlight", {}, 3000)
    )

  updateDataUploadProgress: (id, progress) ->
    @progressBarDivForDataUploadId(id).css(width: "#{progress}%")

  domForDataUploadId: (id) ->
    $("[data-data-upload-row=#{id}]")

  progressBarDivForDataUploadId: (id) ->
    @domForDataUploadId(id).find('[data-status-column] .bar')




