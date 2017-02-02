require('../../vendor/bootstrap-select')

module.exports = class BootstrapSelectInitializer
  constructor: (els, options = {}) ->
    $(els).selectpicker(options)


