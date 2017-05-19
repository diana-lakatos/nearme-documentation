var Fixes;

Fixes = function() {
  function Fixes() {}

  Fixes.enhancements = function() {
    /*
     * Add class .last-child to all relevant elements in older browsers
     */
    if (!document.addEventListener) {
      return $('*:last-child').addClass('last-child');
    }
  };

  Fixes.initialize = function() {
    return this.enhancements();
  };

  return Fixes;
}();

module.exports = Fixes;
