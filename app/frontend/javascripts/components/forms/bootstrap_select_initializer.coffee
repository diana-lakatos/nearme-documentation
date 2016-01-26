require('bootstrap-select/js/bootstrap-select')

module.exports = class BootstrapSelectInitializer
  constructor: (els, options = {})->
    $(els).selectpicker(options)


