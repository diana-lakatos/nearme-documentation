require('select2/select2')

module.exports = class Select2Initializer
  constructor: ->
    @initialize()

  initialize: ->
    $('.select2').each ->
      $select = $(this)

      defaults = {
        minimumResultsForSearch: 20,
        create: true,
        width: '100%',
        # TODO uncomment after upgrade to version 4.0
        # tags: true
      }

      options = $.extend(defaults, {
        placeholder: $select.data('select2-placeholder')
      })

      $select.select2(options)
