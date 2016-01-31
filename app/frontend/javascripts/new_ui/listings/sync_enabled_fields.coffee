# Due to complexity in layout we have two separate fields
# that need to be kept in sync with each other
module.exports = class SyncEnabledFields

  constructor: (fields) ->
    @fields = $(fields)
    @bindEvents()

  bindEvents: =>
    @fields.on 'change', (e)=>
      @fields.prop('checked',$(e.target).is(':checked'))
