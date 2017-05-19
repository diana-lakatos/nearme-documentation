var DatepickerView,
  PositionedView,
  asEvented,
  dateUtil,
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

asEvented = require('asevented');

dateUtil = require('../../lib/utils/date');

PositionedView = require('../lib/positioned_view');

/*
 * Internal display view for datepicker
 */
DatepickerView = function(superClass) {
  extend(DatepickerView, superClass);

  asEvented.call(DatepickerView.prototype);

  DatepickerView.prototype.viewTemplate = '<div class="datepicker-prev ico-arrow-left"></div>\n<div class="datepicker-next ico-arrow-right"></div>\n\n<div class="datepicker-header">\n  <div class="datepicker-month"></div>\n  <div class="datepicker-year"></div>\n</div>\n\n<div class="datepicker-text">\n</div>\n\n<div class="datepicker-week-header">\n  <div class="datepicker-week-heading">S</div>\n  <div class="datepicker-week-heading">M</div>\n  <div class="datepicker-week-heading">T</div>\n  <div class="datepicker-week-heading">W</div>\n  <div class="datepicker-week-heading">T</div>\n  <div class="datepicker-week-heading">F</div>\n  <div class="datepicker-week-heading">S</div>\n</div>\n\n<div class="datepicker-days-wrapper">\n  <div class="datepicker-days"></div>\n  <div class="datepicker-loading"><i></i></div>\n</div>';

  DatepickerView.prototype.dayTemplate = '<div title="<%= title %>" class="<%= klass %>" data-year="<%= year %>" data-month="<%= month %>" data-day="<%= day %>"><%= day %></div>';

  DatepickerView.prototype.defaultOptions = {
    containerClass: 'dnm-datepicker',
    /*
     * Target for positioning of the popover view
     */
    positionTarget: null,
    /*
     * Padding in px as spacing around the positioning popover
     */
    positionPadding: 5,
    /*
     * Whether to disable past dates
     */
    disablePastDates: true,
    /*
     * How many pixels away from the right of the window to force
     * the datepicker to render.
     */
    windowRightPadding: 20
  };

  function DatepickerView(options) {
    var base;
    this.options = options != null ? options : {};
    this.options = $.extend({}, this.defaultOptions, this.options);
    (base = this.options).positionTarget || (base.positionTarget = this.options.trigger);
    DatepickerView.__super__.constructor.call(this, this.options);
    this.container.html(this.viewTemplate);
    this.monthHeader = this.container.find('.datepicker-month');
    this.yearHeader = this.container.find('.datepicker-year');
    this.prev = this.container.find('.datepicker-prev');
    this.next = this.container.find('.datepicker-next');
    this.weekHeader = this.container.find('.datepicker-week-header');
    this.daysContainer = this.container.find('.datepicker-days');
    this.loading = this.container.find('.datepicker-loading').hide();
    if (this.options.text) {
      this.setText(this.options.text);
    }
    this.bindEvents();
  }

  /*
   * Set the model for the view
   */
  DatepickerView.prototype.setModel = function(model) {
    return this.model = model;
  };

  DatepickerView.prototype.setText = function(text) {
    return this.container.find('.datepicker-text').html(text);
  };

  DatepickerView.prototype.show = function() {
    /*
     * Refresh the view on the first display
     */
    if (!this.hasRendered) {
      this.refresh();
    }
    return DatepickerView.__super__.show.apply(this, arguments);
  };

  DatepickerView.prototype.dateAdded = function(date) {
    return this.updateDate(date);
  };

  DatepickerView.prototype.dateRemoved = function(date) {
    return this.updateDate(date);
  };

  DatepickerView.prototype.updateDate = function(date) {
    var klass;
    klass = this.classForDate(date, this.model.getCurrentMonth());
    return this.dateElement(date).removeClass().addClass(klass);
  };

  /*
   * Setup and bind fields within the container
   */
  DatepickerView.prototype.bindEvents = function() {
    /*
     * Clicking on a date element
     */
    this.daysContainer.on(
      'click',
      '.datepicker-day',
      function(_this) {
        return function(event) {
          var d, dayEl, m, y;
          dayEl = $(event.target).closest('.datepicker-day');
          if (dayEl.is('.disabled')) {
            return;
          }
          y = parseInt(dayEl.attr('data-year'), 10);
          m = parseInt(dayEl.attr('data-month'), 10);
          d = parseInt(dayEl.attr('data-day'), 10);
          return _this.trigger('dateClicked', new Date(y, m, d, 0, 0, 0, 0));
        };
      }(this)
    );

    /*
     * Clicking previous/next
     */
    this.prev.on(
      'click',
      function(_this) {
        return function() {
          return _this.trigger('prevClicked');
        };
      }(this)
    );
    return this.next.on(
      'click',
      function(_this) {
        return function() {
          return _this.trigger('nextClicked');
        };
      }(this)
    );
  };

  /*
   * Render all state again
   */
  DatepickerView.prototype.refresh = function() {
    this.activeDate = null;
    this.firstUnavailable = null;
    this.renderMonth(this.model.getCurrentMonth());
    return this.hasRendered = true;
  };

  /*
   * Set loading state
   */
  DatepickerView.prototype.setLoading = function(state) {
    if (state) {
      return this.loading.show();
    } else {
      return this.loading.fadeOut('fast');
    }
  };

  /*
   * Get the day element on the current calendar view, if any.
   */
  DatepickerView.prototype.dateElement = function(date) {
    return this.daysContainer.find(
      '.datepicker-day-' + date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate()
    );
  };

  /*
   * Render a month from a Date object
   */
  DatepickerView.prototype.renderMonth = function(monthDate) {
    /*
     * Set month heading
     */
    var date, html, j, len, ref;
    this.firstUnavailable = null;
    this.monthHeader.text(dateUtil.monthName(monthDate));
    this.yearHeader.text(monthDate.getFullYear());
    html = '';
    ref = this.datesForMonth(monthDate);
    for (j = 0, len = ref.length; j < len; j++) {
      date = ref[j];
      html += this.renderDate(date, monthDate);
    }

    /*
     * Set the html in the days container
     */
    this.daysContainer.html(html);
    return this.reposition();
  };

  /*
   * Get all the dates to render for a given month given that
   * all dates in a week must be rendered.
   */
  DatepickerView.prototype.datesForMonth = function(monthDate) {
    var current, dates, i, j, ref, weeks;
    current = new Date(monthDate.getFullYear(), monthDate.getMonth(), 1, 0, 0, 0, 0);
    current.setDate(current.getDate() - current.getDay());
    weeks = 4;
    while (new Date(
      current.getFullYear(),
      current.getMonth(),
      current.getDate() + weeks * 7,
      0,
      0,
      0,
      0
    ).getMonth() ===
      monthDate.getMonth()) {
      weeks += 1;
    }
    dates = [];
    for (i = j = 0, ref = weeks * 7 - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
      dates.push(new Date(
        current.getFullYear(),
        current.getMonth(),
        current.getDate() + i,
        0,
        0,
        0,
        0
      ));
    }
    return dates;
  };

  DatepickerView.prototype.renderDate = function(date, monthDate) {
    return this._render(this.dayTemplate, {
      year: date.getFullYear(),
      month: date.getMonth(),
      day: date.getDate(),
      dow: date.getDay(),
      klass: this.classForDate(date, monthDate)
    });
  };

  DatepickerView.prototype.classForDate = function(date, monthDate) {
    var klass, now;
    if (monthDate == null) {
      monthDate = null;
    }

    /*
     * Standard date classes
     */
    klass = [
      'datepicker-day',
      'datepicker-day-' + date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate(),
      'datepicker-day-dow-' + date.getDay()
    ];
    if (this.model.isSelected(date)) {
      klass.push('active');
    }
    if (monthDate && monthDate.getMonth() !== date.getMonth()) {
      klass.push('datepicker-day-other-month');
    }
    now = new Date();
    now = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    if (date.getTime() === now.getTime()) {
      klass.push('datepicker-day-today');
    }
    if (date.getTime() < now.getTime()) {
      klass.push('datepicker-day-past');
      if (this.options.disablePastDates) {
        klass.push('disabled');
      }
    }
    return klass.join(' ');
  };

  DatepickerView.prototype._render = function(template, args) {
    return _.template(template)(args);
  };

  return DatepickerView;
}(PositionedView);

module.exports = DatepickerView;
