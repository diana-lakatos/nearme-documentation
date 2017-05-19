var BootstrapSelectInitializer;

require('../../vendor/bootstrap-select');

BootstrapSelectInitializer = function() {
  function BootstrapSelectInitializer(els, options) {
    if (options == null) {
      options = {};
    }
    $(els).selectpicker(options);
  }

  return BootstrapSelectInitializer;
}();

module.exports = BootstrapSelectInitializer;
