/*
 * Due to complexity in layout we have two separate fields
 * that need to be kept in sync with each other
 */
var SyncEnabledFields,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

SyncEnabledFields = function() {
  function SyncEnabledFields(fields) {
    this.bindEvents = bind(this.bindEvents, this);
    this.fields = $(fields);
    this.bindEvents();
  }

  SyncEnabledFields.prototype.bindEvents = function() {
    return this.fields.on(
      'change',
      function(_this) {
        return function(e) {
          return _this.fields.prop('checked', $(e.target).is(':checked'));
        };
      }(this)
    );
  };

  return SyncEnabledFields;
}();

module.exports = SyncEnabledFields;
