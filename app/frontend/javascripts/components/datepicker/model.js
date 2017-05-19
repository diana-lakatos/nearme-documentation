var DatepickerModel, asEvented, dateUtil;

asEvented = require('asevented');

dateUtil = require('../../lib/utils/date');

/*
 * Internal backing model for datepicker data
 */
DatepickerModel = function() {
  asEvented.call(DatepickerModel.prototype);

  DatepickerModel.prototype.defaultOptions = {
    /*
     * The initial month of the view, specified as a Date object
     */
    currentMonth: null,
    /*
     * The 'today' for the view, specified as a Date object
     */
    today: new Date(),
    /*
     * The initial 'selected dates' for the calendar
     */
    selectedDates: [],
    /*
     * Can dates be changed?
     */
    immutable: false
  };

  function DatepickerModel(options) {
    this.options = options;
    this.options = $.extend({}, this.defaultOptions, this.options);
    this.currentMonth = this.options.currentMonth;
    this.immutable = this.options.immutable;
    this._included = [];
    this.today = this.options.today;
    if (this.options.selectedDates) {
      this.setDates(this.options.selectedDates);
    }
  }

  DatepickerModel.prototype.advanceMonth = function(incr) {
    if (incr == null) {
      incr = 1;
    }
    this.currentMonth = new Date(
      this.currentMonth.getFullYear(),
      this.currentMonth.getMonth() + incr,
      1,
      0,
      0,
      0,
      0
    );
    return this.trigger('monthChanged', this.currentMonth);
  };

  DatepickerModel.prototype.setCurrentMonth = function(newMonth) {
    this.currentMonth = new Date(newMonth.getFullYear(), newMonth.getMonth(), 1, 0, 0, 0, 0);
    return this.trigger('monthChanged', this.currentMonth);
  };

  DatepickerModel.prototype.getCurrentMonth = function() {
    return this.currentMonth || (this.currentMonth = _.last(this.getDates()) || new Date());
  };

  DatepickerModel.prototype.isSelected = function(date) {
    return _.contains(this._included, this._asId(date));
  };

  DatepickerModel.prototype.getDates = function() {
    var dates;
    dates = _.map(
      this._included,
      function(_this) {
        return function(dateId) {
          return _this._fromId(dateId);
        };
      }(this)
    );
    return _.sortBy(dates, function(date) {
      return date.getTime();
    });
  };

  DatepickerModel.prototype.toggleDate = function(date) {
    if (this.immutable) {
      return;
    }
    if (this.isSelected(date)) {
      return this.removeDate(date);
    } else {
      return this.addDate(date);
    }
  };

  DatepickerModel.prototype.removeDate = function(date) {
    if (this._removeDate(date)) {
      return this.trigger('dateRemoved', date);
    }
  };

  DatepickerModel.prototype.addDate = function(date) {
    if (this._addDate(date)) {
      return this.trigger('dateAdded', date);
    }
  };

  DatepickerModel.prototype.setDates = function(dates) {
    var added, date, i, j, k, len, len1, len2, newDates, removed, results;
    newDates = [];
    for (i = 0, len = dates.length; i < len; i++) {
      date = dates[i];
      newDates.push(this._asId(date));
    }
    added = _.difference(newDates, this._included);
    removed = _.difference(this._included, newDates);
    for (j = 0, len1 = removed.length; j < len1; j++) {
      date = removed[j];
      this.removeDate(this._fromId(date));
    }
    results = [];
    for (k = 0, len2 = added.length; k < len2; k++) {
      date = added[k];
      results.push(this.addDate(this._fromId(date)));
    }
    return results;
  };

  DatepickerModel.prototype.clear = function() {
    return this.setDates([]);
  };

  DatepickerModel.prototype._addDate = function(date) {
    var dateId;
    dateId = this._asId(date);
    if (this.isSelected(dateId)) {
      return;
    }
    this._included.push(dateId);
    return true;
  };

  DatepickerModel.prototype._removeDate = function(date) {
    var dateId;
    dateId = this._asId(date);
    if (!this.isSelected(dateId)) {
      return;
    }
    this._included.splice(_.indexOf(this._included, dateId), 1);
    return true;
  };

  DatepickerModel.prototype._asId = function(date) {
    return dateUtil.toId(date);
  };

  DatepickerModel.prototype._fromId = function(dateId) {
    return dateUtil.idToDate(dateId);
  };

  return DatepickerModel;
}();

module.exports = DatepickerModel;
