var DatepickerModel,
  DatepickerSingle,
  extend = function(child, parent) {
    for (var key in parent) {
      if (hasProp.call(parent, key))
        child[key] = parent[key];
    }
    function ctor() {
      this.constructor = child;
    }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype;
    return child;
  },
  hasProp = {}.hasOwnProperty;

DatepickerModel = require('./model');

/*
 * A special case of the datepicker backing model that only allows the selection of
 * a single date.
 */
DatepickerSingle = function(superClass) {
  extend(DatepickerSingle, superClass);

  function DatepickerSingle() {
    return DatepickerSingle.__super__.constructor.apply(this, arguments);
  }

  DatepickerSingle.prototype.defaultOptions = $.extend(
    {},
    DatepickerSingle.prototype.defaultOptions,
    {
      /*
     * Allow deselecting the current active date
     */
      allowDeselection: true
    }
  );

  DatepickerSingle.prototype.toggleDate = function(date) {
    /*
     * Check to see if we allow deselection
     */
    if (!this.options.allowDeselection && this.isSelected(date)) {
      return;
    }
    return DatepickerSingle.__super__.toggleDate.call(this, date);
  };

  DatepickerSingle.prototype.addDate = function(date) {
    if (this._included.length > 0) {
      this.removeDate(this._fromId(this._included[0]));
    }
    return DatepickerSingle.__super__.addDate.call(this, date);
  };

  return DatepickerSingle;
}(DatepickerModel);

module.exports = DatepickerSingle;
