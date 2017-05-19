var DatepickerView,
  SearchRangeDatepickerView,
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

DatepickerView = require('../../components/datepicker/view');

/*
 * A special view to handle rendering the month highlighting the days between
 * the 'start datepicker' and the 'end datepicker'
 */
SearchRangeDatepickerView = function(superClass) {
  extend(SearchRangeDatepickerView, superClass);

  function SearchRangeDatepickerView(startDatepicker, options) {
    this.startDatepicker = startDatepicker;
    if (options == null) {
      options = {};
    }
    SearchRangeDatepickerView.__super__.constructor.call(this, options);
  }

  SearchRangeDatepickerView.prototype.show = function() {
    SearchRangeDatepickerView.__super__.show.apply(this, arguments);

    /*
     * Refresh every time it's opened. We do this because if the start-date has changed, the
     * dates in between start-end would not have refreshed.
     */
    return this.refresh();
  };

  /*
   * The default 'update date' is fired when a date is selected. However, since we have custom
   * rendering for other dates in the month, we also need to update those days. So we just
   * do a full refresh of the current month being displayed.
   */
  SearchRangeDatepickerView.prototype.updateDate = function() {
    return this.refresh();
  };

  SearchRangeDatepickerView.prototype.classForDate = function(date, month) {
    var endDate, klass, startDate;
    klass = [ SearchRangeDatepickerView.__super__.classForDate.call(this, date, month) ];
    startDate = this.startDatepicker.getDates()[0];
    endDate = this.model.getDates()[0] || startDate;
    if (startDate) {
      /*
       * Depending on where the current date being rendered fits in our current
       * range, we assign relevant css classes for display.
       */
      if (endDate.getTime() === date.getTime()) {
        klass.push('active');
      } else if (date.getTime() >= startDate.getTime() && date.getTime() <= endDate.getTime()) {
        klass.push('active implicit');
      } else if (date.getTime() < startDate.getTime()) {
        klass.push('disabled closed');
      }
    }
    return klass.join(' ');
  };

  return SearchRangeDatepickerView;
}(DatepickerView);

module.exports = SearchRangeDatepickerView;
