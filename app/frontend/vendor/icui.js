var hasProp = {}.hasOwnProperty,
  slice = [].slice,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  },
  extend = function(child, parent) {
    for (var key in parent) {
      if (hasProp.call(parent, key)) child[key] = parent[key];
    }
    function ctor() {
      this.constructor = child;
    }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype;
    return child;
  };

require('./gf3-strftime');

/*
 * ICUI
 * ====
 *
 * ICUI is a user interface componenet for constructing repetion
 * schedules for the Ruby [IceCube](https://github.com/seejohnrun/ice_cube)
 * library.
 */

(function($) {
  /*
   * Helpers
   * -------
   */
  var Count,
    DatePicker,
    Day,
    DayOfMonth,
    DayOfWeek,
    DayOfYear,
    EndTime,
    Helpers,
    HourOfDay,
    ICUI,
    MinuteOfHour,
    OffsetFromPascha,
    Option,
    Root,
    Rule,
    StartDate,
    TopLevel,
    Until,
    Validation,
    ValidationInstance,
    clone;
  Helpers = {
    /* `clone` will make a copy of an object including all child object. */
    clone: (clone = function(obj) {
      var flags, key, newInstance;
      if (obj == null || typeof obj !== 'object') {
        return obj;
      }
      if (obj instanceof Date) {
        return new Date(obj.getTime());
      }
      if (obj instanceof RegExp) {
        flags = '';
        if (obj.global != null) {
          flags += 'g';
        }
        if (obj.ignoreCase != null) {
          flags += 'i';
        }
        if (obj.multiline != null) {
          flags += 'm';
        }
        if (obj.sticky != null) {
          flags += 'y';
        }
        return new RegExp(obj.source, flags);
      }

      /*
       * Some care is taken to avoid cloning the parent class,
       * as each ICUI object holds both a reference to a child objects
       * as well as to it's own parent, which could is a cyclic reference.
       */
      if (obj.parent != null && obj.data != null) {
        /*
         * A special case `__clone` parameter is passed to constructors
         * so as to be able to avoid actual initialization.
         */
        newInstance = new obj.constructor(obj.parent, '__clone');
        newInstance.data = clone(obj.data);
      } else {
        newInstance = new obj.constructor();
      }
      for (key in obj) {
        if (!hasProp.call(obj, key)) continue;
        if (
          key !== 'parent' && key !== 'data' && key !== 'elem' && typeof obj[key] !== 'function'
        ) {
          newInstance[key] = clone(obj[key]);
        }
      }
      return newInstance;
    }),

    /*
     * `option` constructs an option for a select where it handles the
     * case when to add the `selected` attribute. The third argument can
     * optionally be a function, otherwise it compare the third argument
     * with the first and if equal mark the option as selected.
     */
    option: function(value, name, varOrFunc) {
      var selected;
      if (typeof varOrFunc === 'function') {
        selected = varOrFunc(value);
      } else {
        selected = varOrFunc === value;
      }
      return (
        '<option value="' +
        value +
        '"' +
        (selected ? ' selected="selected"' : '') +
        '>' +
        name +
        '</option>'
      );
    },

    /* `select` will genearate a `<select>` tag. */
    select: function(varOrFunc, obj) {
      var label, str, value;
      str = '<select>';
      for (value in obj) {
        label = obj[value];
        str += Helpers.option(value, label, varOrFunc);
      }
      return str + '</select>';
    },
    daysOfTheWeek: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],

    /*
     * THis is a wrapper for the most ridicilous API in probably the whole of
     * JavaScript.
     */
    dateFromString: function(str) {
      var d, date, h, m, min, ref, ref1, ref2, rest, t, time, tz, y;
      if (typeof str !== 'string') {
        str = str.time;
      }
      (ref = str.split(/[\sT]/)), (date = ref[0]), (time = ref[1]);
      (ref1 = (function() {
        var j, len, ref1, results;
        ref1 = date.split('-');
        results = [];
        for ((j = 0), (len = ref1.length); j < len; j++) {
          t = ref1[j];
          results.push(parseInt(t, 10));
        }
        return results;
      })()), (y = ref1[0]), (m = ref1[1]), (d = ref1[2]);
      (ref2 = (function() {
        var j, len, ref2, results;
        ref2 = time.split(':');
        results = [];
        for ((j = 0), (len = ref2.length); j < len; j++) {
          t = ref2[j];
          results.push(parseInt(t, 10));
        }
        return results;
      })()), (h = ref2[0]), (min = ref2[1]), (rest = 3 <= ref2.length ? slice.call(ref2, 2) : []);
      m = m - 1 >= 0 ? m - 1 : 11;
      tz = new Date().getTimezoneOffset();
      return new Date(Date.UTC(y, m, d, h, min, 0, 0));
    }
  };

  /*
   * The Base Class
   * --------------
   *
   * Option is the class from which nearly all other classes in ICUI
   * inherit. A number of function are meant to be overriden.
   */
  Option = (function() {
    function Option(parent, data) {
      this.parent = parent;
      if (data == null) {
        data = null;
      }
      this.destroy = bind(this.destroy, this);
      this.clone = bind(this.clone, this);
      this.children = [];
      this.data = {};
      if (data !== '__clone') {
        if (data != null) {
          this.fromData(data);
        } else {
          this.defaults();
        }
      }
    }

    /*
     * `fromData` is meant as an initializer to which the relevant part
     * of the JSON representation is passed at startup.
     */

    Option.prototype.fromData = function(data) {};

    /*
     * Defaults is the initializer used typically for instances constructed
     * as the default child of a parent.
     */

    Option.prototype.defaults = function() {};

    /* When `clonable` is `true` the + button will appear. */

    Option.prototype.clonable = function() {
      return true;
    };

    /* When `destroyable` is `true` the - button will appear. */

    Option.prototype.destroyable = function() {
      return this.parent.children.length > 1;
    };

    /*
     * `clone` is the event handler that will insert a copy of the
     * reciever as a sibling to the reciever.
     */

    Option.prototype.clone = function() {
      this.parent.children.push(Helpers.clone(this));
      return this.triggerRender();
    };

    /*
     * `destroy` will remove the reciever from it's parents list
     * of children.
     */

    Option.prototype.destroy = function() {
      return this.elem.slideUp(
        100,
        (function(_this) {
          return function() {
            var child, has_negative_rules, has_positive_rules, j, len, ref;
            _this.parent.children.splice(_this.parent.children.indexOf(_this), 1);
            if (_this instanceof TopLevel) {
              ref = _this.parent.children;
              for ((j = 0), (len = ref.length); j < len; j++) {
                child = ref[j];
                if (!(child instanceof TopLevel)) {
                  continue;
                }
                if (child.isNegative()) {
                  has_negative_rules = child;
                }
                if (child.isPositive()) {
                  has_positive_rules = child;
                }
              }
              if (has_negative_rules == null) {
                _this.parent.has_negative_rules = false;
              }
              if (has_positive_rules == null) {
                _this.parent.has_positive_rules = false;
              }
            }
            if (_this instanceof EndTime) {
              _this.parent.has_ending_time = false;
            }
            return _this.parent.triggerRender();
          };
        })(this)
      );
    };

    /*
     * Render is the code that is responsible for setting up an
     * HTML fragment and binding all the necessary UI callbacks
     * onto it. It is recommended to call super as this will make
     * all the child objects render as wall as displays the generic
     * cloning UI.
     */

    Option.prototype.render = function() {
      var buttons, out;
      out = $('<div></div>');
      buttons = $("<div class='col-md-2 small-padding text-right'></div>");
      if (this.clonable()) {
        buttons.append($("<span class='btn clone'>+</span>").click(this.clone));
      }
      if (this.destroyable()) {
        buttons.append($("<span class='btn destroy'>-</span>").click(this.destroy));
      }
      out.append(buttons);
      out.append(this.renderChildren());
      return out.children();
    };

    Option.prototype.renderChildren = function() {
      var c, j, len, ref, results;
      ref = this.children;
      results = [];
      for ((j = 0), (len = ref.length); j < len; j++) {
        c = ref[j];
        results.push(c.render());
      }
      return results;
    };

    /*
     * This will trigger a rerender for the whole structure without needing
     * to keep a global reference to the root node.
     */

    Option.prototype.triggerRender = function() {
      return this.parent.triggerRender();
    };

    return Option;
  })();

  /*
   * The Root Node
   * -------------
   *
   * `Root` is meant as a singleton class (although this is not enforced).
   * It holds inside itself all other nodes and is responsible for actually
   * putting the whole structure into the DOM.
   */
  Root = (function(superClass) {
    extend(Root, superClass);

    Root.prototype.clonable = function() {
      return false;
    };

    Root.prototype.destroyable = function() {
      return false;
    };

    Root.prototype.has_ending_time = false;

    Root.prototype.has_positive_rules = false;

    Root.prototype.has_negative_rules = false;

    function Root() {
      Root.__super__.constructor.apply(this, arguments);

      /*
       * The parent of the root node is the jQuerified element
       * itself, this will typically be an `<input type="hidden">`.
       * We insert our container div after it and save it into the
       * `@target` variable.
       */
      this.parent.after(
        "<div class='icui'><div class='positive-rules'></div><div class='negative-rules'></div></div>"
      );
      this.target = this.parent.siblings('.icui');
      this.positive_target = this.target.find('.positive-rules').first();
      this.negative_target = this.target.find('.negative-rules').first();
    }

    Root.prototype.fromData = function(d) {
      var k, results, v;
      this.children.push(new StartDate(this, d['start_date']));
      if (d['end_time']) {
        this.has_ending_time = true;
        this.children.push(new EndTime(this, d['end_time']));
      }
      results = [];
      for (k in d) {
        v = d[k];
        if (!(v.length > 0 && k !== 'start_date' && k !== 'end_time' && k !== 'start_time')) {
          continue;
        }
        if (k.match(/^r/)) {
          this.has_positive_rules = true;
        } else if (k.match(/^ex/)) {
          this.has_negative_rules = true;
        }
        results.push(
          this.children.push(
            new TopLevel(this, {
              type: k,
              values: v
            })
          )
        );
      }
      return results;
    };

    Root.prototype.defaults = function() {
      return this.children.push(new StartDate(this));

      /*
      #@children.push new TopLevel(@)
       */
    };

    Root.prototype.triggerRender = function() {
      return this.render();
    };

    Root.prototype.render = function() {
      var link, negative_link, positive_link;
      this.positive_target.html(this.renderPositiveChildren());
      this.negative_target.html(this.renderNegativeChildren());
      if (!(this.has_ending_time || true)) {
        link = $(
          "<div class='row'><a href='#'>" + this.parent.data('add-duration') + '</a></div> '
        );
        link.click(
          (function(_this) {
            return function() {
              _this.has_ending_time = true;
              link.hide();
              _this.children.push(new EndTime(_this));
              _this.triggerRender();
              return false;
            };
          })(this)
        );
        this.positive_target.append(link);
      }
      if (!this.has_positive_rules) {
        positive_link = $(
          "<div class='row'><a href='#'>" + this.parent.data('add-availability') + '</a></div>'
        );
        positive_link.click(
          (function(_this) {
            return function() {
              _this.has_positive_rules = true;
              positive_link.hide();
              _this.children.push(new TopLevel(_this));
              _this.triggerRender();
              return false;
            };
          })(this)
        );
        this.positive_target.append(positive_link);
      }
      if (!this.has_negative_rules) {
        negative_link = $(
          "<div class='row'><a href='#'>" + this.parent.data('add-unavailable') + '</a></div>'
        );
        negative_link.click(
          (function(_this) {
            return function() {
              var top_level;
              _this.has_negative_rules = true;
              negative_link.hide();
              top_level = new TopLevel(_this);
              top_level.data.type = 'extimes';
              top_level.children = [new DatePicker(top_level)];
              _this.children.push(top_level);
              _this.triggerRender();
              return false;
            };
          })(this)
        );
        this.negative_target.append(negative_link);
      }
      return '';
    };

    Root.prototype.renderPositiveChildren = function() {
      var arr, child, j, len, ref;
      arr = [];
      arr.push($('<h4>' + this.parent.data('availability') + '</h4>'));
      ref = this.children;
      for ((j = 0), (len = ref.length); j < len; j++) {
        child = ref[j];
        if (!(child instanceof TopLevel && child.isNegative())) {
          arr.push(child.render());
        }
      }
      return arr;
    };

    Root.prototype.renderNegativeChildren = function() {
      var arr, child, j, len, ref;
      arr = [];
      arr.push($('<h4>' + this.parent.data('unavailable') + '</h4>'));
      ref = this.children;
      for ((j = 0), (len = ref.length); j < len; j++) {
        child = ref[j];
        if (child instanceof TopLevel && child.isNegative()) {
          arr.push(child.render());
        }
      }
      return arr;
    };

    Root.prototype.getData = function() {
      var child, d, data, j, len, ref;
      data = {};
      ref = this.children;
      for ((j = 0), (len = ref.length); j < len; j++) {
        child = ref[j];
        d = child.getData();
        if (data[d.type]) {
          data[d.type] = data[d.type].concat(d.values);
        } else {
          data[d.type] = d.values;
        }
      }
      return data;
    };

    return Root;
  })(Option);

  /*
   * TopLevel
   * --------
   * The `TopLevel` class let's the user pick whether he would like
   * to add or remove dates or rules.
   *
   * Each of these alternatives than spawns a default child.
   *
   * The total class diagram looks like this:
   *
   *     Root
   *     |- StartDate
   *     `- TopLevel +-
   *        |- DatePicker +-
   *        `- Rule +-
   *           `- Validation +-
   *              |- Count
   *              |- Until
   *              |- Day +-
   *              |- HourOfDay +-
   *              |- MinuteOfHour +-
   *              |- DayOfWeek +-
   *              |- DayOfMonth +-
   *              |- DayOfYear +-
   *              `- OffsetFromPascha +-
   */
  TopLevel = (function(superClass) {
    extend(TopLevel, superClass);

    function TopLevel() {
      return TopLevel.__super__.constructor.apply(this, arguments);
    }

    TopLevel.prototype.defaults = function() {
      this.data.type = 'rrules';
      return (this.children = [new Rule(this)]);
    };

    TopLevel.prototype.fromData = function(d) {
      var j, l, len, len1, ref, ref1, results, results1, v;
      this.data.type = d.type;
      if (this.data.type.match(/times$/)) {
        ref = d.values;
        results = [];
        for ((j = 0), (len = ref.length); j < len; j++) {
          v = ref[j];
          results.push(this.children.push(new DatePicker(this, v)));
        }
        return results;
      } else {
        ref1 = d.values;
        results1 = [];
        for ((l = 0), (len1 = ref1.length); l < len1; l++) {
          v = ref1[l];
          results1.push(this.children.push(new Rule(this, v)));
        }
        return results1;
      }
    };

    TopLevel.prototype.getData = function() {
      var child, values;
      if (this.data.type.match(/times$/)) {
        values = function() {
          var j, len, ref, results;
          ref = this.children;
          results = [];
          for ((j = 0), (len = ref.length); j < len; j++) {
            child = ref[j];
            results.push(child.getData().time);
          }
          return results;
        }.call(this);
        return {
          type: this.data.type,
          values: values
        };
      } else {
        values = function() {
          var j, len, ref, results;
          ref = this.children;
          results = [];
          for ((j = 0), (len = ref.length); j < len; j++) {
            child = ref[j];
            results.push(child.getData());
          }
          return results;
        }.call(this);
        return {
          type: this.data.type,
          values: values
        };
      }
    };

    TopLevel.prototype.isPositive = function() {
      return this.data.type.match(/^r/);
    };

    TopLevel.prototype.isNegative = function() {
      return this.data.type.match(/^ex/);
    };

    TopLevel.prototype.render = function() {
      var children, row, ss;
      this.elem = $(
        '<div class="toplevel">\n  <div class=\'row\'>\n    <div class="col-md-2 label"><label>' +
          this.parent.parent.data('event') +
          '</label></div>\n    <div class="col-md-4 small-padding hidden">\n      <select class="select required selectpicker">\n        ' +
          Helpers.option(
            1,
            'occurs',
            (function(_this) {
              return function() {
                return _this.data.type.match(/^r/);
              };
            })(this)
          ) +
          '\n        ' +
          Helpers.option(
            -1,
            "doesn't occur",
            (function(_this) {
              return function() {
                return _this.data.type.match(/^ex/);
              };
            })(this)
          ) +
          '\n      </select>\n    </div>\n    <div class="col-md-8 small-padding big-input">\n      <select>\n        ' +
          Helpers.option(
            'dates',
            '' + this.parent.parent.data('specific-dates'),
            (function(_this) {
              return function() {
                return _this.data.type.match(/times$/);
              };
            })(this)
          ) +
          '\n        ' +
          Helpers.option(
            'rules',
            '' + this.parent.parent.data('every'),
            (function(_this) {
              return function() {
                return _this.data.type.match(/rules$/);
              };
            })(this)
          ) +
          '\n      </select>\n    </div>\n  </div>\n</div>'
      );
      ss = this.elem.find('select');
      ss.first().change(
        (function(_this) {
          return function(e) {
            if (e.target.value === '1') {
              return (_this.data.type = _this.data.type.replace(/^ex/, 'r'));
            } else {
              return (_this.data.type = _this.data.type.replace(/^r/, 'ex'));
            }
          };
        })(this)
      );
      ss.last().change(
        (function(_this) {
          return function(e) {
            if (e.target.value === 'dates') {
              if (_this.data.type.match(/^r/)) {
                _this.data.type = 'rtimes';
              } else {
                _this.data.type = 'extimes';
              }
              _this.children = [new DatePicker(_this)];
            } else {
              if (_this.data.type.match(/^r/)) {
                _this.data.type = 'rrules';
              } else {
                _this.data.type = 'exrules';
              }
              _this.children = [new Rule(_this)];
            }
            return _this.triggerRender();
          };
        })(this)
      );
      row = this.elem.find('div.row');
      children = TopLevel.__super__.render.apply(this, arguments).toArray();
      row.append(children.shift());
      this.elem.append(children);
      if ($.prototype.selectpicker != null) {
        this.elem.find('select').selectpicker();
      }
      return this.elem;
    };

    return TopLevel;
  })(Option);

  /*
   * Choosing Individual DateTimes
   * -----------------------------
   *
   * The DatePicker class allows the user to pick an individual date and
   * time. Currently it relies on HTML5 attributes to provide most of the
   * user interface, however we could probably easily extend this to use
   * something like jQuery UI.
   */
  DatePicker = (function(superClass) {
    extend(DatePicker, superClass);

    function DatePicker() {
      return DatePicker.__super__.constructor.apply(this, arguments);
    }

    DatePicker.prototype.defaults = function() {
      var base;
      return (base = this.data).time != null ? base.time : (base.time = new Date());
    };

    DatePicker.prototype.fromData = function(d) {
      return (this.data.time = Helpers.dateFromString(d));
    };

    DatePicker.prototype.getData = function() {
      return this.data;
    };

    DatePicker.prototype.render = function() {
      var date, ss, time;
      this.elem = $(
        '<div class="DatePicker row">\n  <div class="col-md-2 label">\n    <label>' +
          (this.getData().label || '') +
          '</label>\n  </div>\n  <div class="col-md-4 small-padding">\n    <input type="text" data-type="date" value="' +
          this.data.time.strftime('%Y-%m-%d') +
          '" />\n  </div>\n  <div class="col-md-4 small-padding">\n    <input type="time" value="' +
          this.data.time.strftime('%H:%M') +
          '" />\n  </div>\n</div>'
      );
      ss = this.elem.find('input');
      date = ss.first();
      time = ss.last();
      ss.change(
        (function(_this) {
          return function(e) {
            return (_this.data.time = Helpers.dateFromString(date.val() + ' ' + time.val()));
          };
        })(this)
      );
      this.elem.find("input[data-type='date']").datepicker({
        dateFormat: 'yy-mm-dd',
        altFormat: 'yy-mm-dd'
      });
      this.elem.append(DatePicker.__super__.render.apply(this, arguments));
      return this.elem;
    };

    return DatePicker;
  })(Option);

  /*
   * Picking the initial Date
   * ------------------------
   * `StartDate` is a concrete DatePicker subclass that takes care of picking
   * the initial date. The main diffrence is that it is unclonable.
   */
  StartDate = (function(superClass) {
    extend(StartDate, superClass);

    function StartDate() {
      return StartDate.__super__.constructor.apply(this, arguments);
    }

    StartDate.prototype.destroyable = function() {
      return false;
    };

    StartDate.prototype.clonable = function() {
      return false;
    };

    StartDate.prototype.getData = function() {
      return {
        type: 'start_date',
        values: this.data.time,
        label: this.parent.parent.data('start-time')
      };
    };

    StartDate.prototype.render = function() {
      this.elem = StartDate.__super__.render.apply(this, arguments);
      return this.elem;
    };

    return StartDate;
  })(DatePicker);

  /*
   * Picking the ending Date
   * -----------------------
   * `EndTime` is a concrete DatePicker subclass that takes care of picking
   * the ending date. The main diffrence is that it is unclonable.
   */
  EndTime = (function(superClass) {
    extend(EndTime, superClass);

    function EndTime() {
      return EndTime.__super__.constructor.apply(this, arguments);
    }

    EndTime.prototype.destroyable = function() {
      return true;
    };

    EndTime.prototype.clonable = function() {
      return false;
    };

    EndTime.prototype.getData = function() {
      return {
        type: 'end_time',
        values: this.data.time,
        label: this.parent.parent.data('duration')
      };
    };

    EndTime.prototype.render = function() {
      this.elem = EndTime.__super__.render.apply(this, arguments);
      return this.elem;
    };

    return EndTime;
  })(DatePicker);

  /*
   * Specifying Rules
   * ----------------
   * Rules specify a sort of generator which than validations filter out.
   * So the `YearlyRule` will generate thing which happen roughly once per
   * year.
   */
  Rule = (function(superClass) {
    extend(Rule, superClass);

    function Rule() {
      return Rule.__super__.constructor.apply(this, arguments);
    }

    Rule.prototype.defaults = function() {
      this.data.rule_type = 'IceCube::WeeklyRule';
      this.children = [new Validation(this)];
      return (this.data.interval = 1);
    };

    Rule.prototype.fromData = function(d) {
      var k, ref, results, v;
      this.data.rule_type = d.rule_type;
      this.data.interval = d.interval;
      if (d.count) {
        this.children.push(
          new Validation(this, {
            type: 'count',
            value: d.count
          })
        );
      }
      if (d.until) {
        this.children.push(
          new Validation(this, {
            type: 'until',
            value: d.until
          })
        );
      }
      ref = d.validations;
      results = [];
      for (k in ref) {
        v = ref[k];
        results.push(
          this.children.push(
            new Validation(this, {
              type: k,
              value: v
            })
          )
        );
      }
      return results;
    };

    Rule.prototype.getData = function() {
      var child, h, j, k, l, len, len1, ref, ref1, ref2, ref3, v, validations;
      validations = {};
      ref = this.children;
      for ((j = 0), (len = ref.length); j < len; j++) {
        child = ref[j];
        if (child.data.type !== 'count' && child.data.type !== 'until') {
          ref1 = child.getData();
          for (k in ref1) {
            v = ref1[k];
            validations[k] = v;
          }
        }
      }
      h = {
        rule_type: this.data.rule_type,
        interval: this.data.interval,
        validations: validations
      };
      ref2 = this.children;
      for ((l = 0), (len1 = ref2.length); l < len1; l++) {
        child = ref2[l];
        if (child.data.type === 'count' || child.data.type === 'until') {
          ref3 = child.getData();
          for (k in ref3) {
            v = ref3[k];
            h[k] = v;
          }
        }
      }
      return h;
    };

    Rule.prototype.render = function() {
      var children, row;
      this.elem = $(
        '<div class="Rule">\n  <div class="row">\n    <div class="col-md-2"></div>\n    <div class="col-md-4 small-padding">\n      <input type="number" value="' +
          this.data.interval +
          '" size="2" width="30" min="1" />\n    </div>\n    <div class="col-md-4 small-padding">\n      ' +
          Helpers.select(this.data.rule_type, {
            'IceCube::YearlyRule': 'years',
            'IceCube::MonthlyRule': 'months',
            'IceCube::WeeklyRule': 'weeks',
            'IceCube::DailyRule': 'days'
          }) +
          '\n    </div>\n  </div>\n</div>'
      );
      this.elem.find('input').change(
        (function(_this) {
          return function(e) {
            return (_this.data.interval = parseInt(e.target.value));
          };
        })(this)
      );
      this.elem.find('select').change(
        (function(_this) {
          return function(e) {
            _this.data.rule_type = e.target.value;
            if (_this.data.rule_type === 'IceCube::HourlyRule') {
              _this.children = [
                new Validation(_this, {
                  type: 'count'
                })
              ];
            } else {
              _this.children = [new Validation(_this)];
            }
            return _this.triggerRender();
          };
        })(this)
      );
      row = this.elem.find('div.row');
      children = Rule.__super__.render.apply(this, arguments).toArray();
      row.append(children.shift());
      this.elem.append(children);
      return this.elem;
    };

    return Rule;
  })(Option);

  /*
   * Validation
   * ----------
   * Validation let's the user pick what type of validation to use
   * and also agregates the arguments to the validation.
   */
  Validation = (function(superClass) {
    extend(Validation, superClass);

    function Validation() {
      return Validation.__super__.constructor.apply(this, arguments);
    }

    Validation.prototype.defaults = function() {
      this.data.type = 'day';
      return (this.children = [new Day(this)]);
    };

    Validation.prototype.fromData = function(d) {
      var c, j, k, klass, l, len, len1, ref, ref1, ref2, results, results1, results2, v, vals;
      this.data.type = d.type;
      switch (d.type) {
        case 'count':
          return this.children.push(new Count(this, d.value));
        case 'until':
          return this.children.push(new Until(this, d.value));
        case 'day':
          ref = d.value;
          results = [];
          for ((j = 0), (len = ref.length); j < len; j++) {
            v = ref[j];
            results.push(this.children.push(new Day(this, v)));
          }
          return results;
          break;
        case 'day_of_week':
          ref1 = d.value;
          results1 = [];
          for (k in ref1) {
            vals = ref1[k];
            results1.push(
              function() {
                var l, len1, results2;
                results2 = [];
                for ((l = 0), (len1 = vals.length); l < len1; l++) {
                  v = vals[l];
                  results2.push(
                    this.children.push(
                      new DayOfWeek(this, {
                        nth: v,
                        day: k
                      })
                    )
                  );
                }
                return results2;
              }.call(this)
            );
          }
          return results1;
          break;
        default:
          ref2 = d.value;
          results2 = [];
          for ((l = 0), (len1 = ref2.length); l < len1; l++) {
            v = ref2[l];
            klass = this.choices(d.type);
            c = new klass(this, v);
            results2.push(this.children.push(c));
          }
          return results2;
      }
    };

    Validation.prototype.choices = function(v) {
      return {
        count: Count,
        until: Until,
        day: Day,
        hour_of_day: HourOfDay,
        minute_of_hour: MinuteOfHour,
        day_of_week: DayOfWeek,
        day_of_month: DayOfMonth,
        day_of_year: DayOfYear,
        offset_from_pascha: OffsetFromPascha
      }[v];
    };

    Validation.prototype.getData = function() {
      var child, k, key, obj, v, value;
      key = this.data.type;
      value = function() {
        var j, l, len, len1, ref, ref1, ref2, results;
        switch (key) {
          case 'count':
            return this.children[0].getData();
          case 'until':
            return this.children[0].getData();
          case 'day_of_week':
            obj = {};
            ref = this.children;
            for ((j = 0), (len = ref.length); j < len; j++) {
              child = ref[j];
              (ref1 = child.getData()), (k = ref1[0]), (v = ref1[1]);
              if (obj[k] == null) {
                obj[k] = [];
              }
              obj[k].push(v);
            }
            return obj;
          default:
            ref2 = this.children;
            results = [];
            for ((l = 0), (len1 = ref2.length); l < len1; l++) {
              child = ref2[l];
              results.push(child.getData());
            }
            return results;
        }
      }.call(this);
      obj = {};
      obj[key] = value;
      return obj;
    };

    Validation.prototype.destroyable = function() {
      return true;
    };

    Validation.prototype.render = function() {
      var children, ref, ref1, row, str, translation_holder;
      translation_holder = (this.parent.parent
        ? this.parent.parent.parent ? this.parent.parent.parent : this.parent.parent
        : this.parent).parent;
      str =
        '<div class="Validation">\n  <div class="row">\n    <div class="col-md-2 label">\n      <label>' +
        (this.parent.children.indexOf(this) > 0 ? 'and if' : 'If') +
        '</label>\n    </div>\n    <div class="col-md-8 small-padding">\n      <select>\n        ' +
        Helpers.option('count', translation_holder.data('event-occured-less'), this.data.type);
      if (
        (ref = this.parent.data.rule_type) === 'IceCube::YearlyRule' ||
        ref === 'IceCube::MonthlyRule' ||
        ref === 'IceCube::WeeklyRule' ||
        ref === 'IceCube::DailyRule' ||
        ref === 'IceCube::HourlyRule'
      ) {
        str += Helpers.option('until', translation_holder.data('event-before'), this.data.type);
        str += Helpers.option('day', translation_holder.data('this-day-of-week'), this.data.type);
        str += Helpers.option(
          'hour_of_day',
          translation_holder.data('this-hour-of-day'),
          this.data.type
        );
        str += Helpers.option(
          'minute_of_hour',
          translation_holder.data('this-minute-of-hour'),
          this.data.type
        );
      }
      if (
        (ref1 = this.parent.data.rule_type) === 'IceCube::YearlyRule' ||
        ref1 === 'IceCube::MonthlyRule'
      ) {
        str += Helpers.option(
          'day_of_week',
          translation_holder.data('this-day-of-nth-week'),
          this.data.type
        );
        str += Helpers.option(
          'day_of_month',
          translation_holder.data('this-nth-day-of-month'),
          this.data.type
        );
      }
      if (this.parent.data.rule_type === 'IceCube::YearlyRule') {
        str += Helpers.option(
          'day_of_year',
          translation_holder.data('this-nth-day-of-year'),
          this.data.type
        );
        str += Helpers.option(
          'offset_from_pascha',
          translation_holder.data('pascha-offset'),
          this.data.type
        );
      }
      str += '      </select>\n    </div>\n  <div>\n</div>';
      this.elem = $(str);
      this.elem.find('select').change(
        (function(_this) {
          return function(e) {
            /*
           * switch e.target.value
           *          when 'count' then @children = [new Count @]
           *          when 'day' then @children = [new Day @]
           *          when 'day_of_week' then @children = [new DayOfWeek @]
           *          when 'day_of_month' then @children = [new DayOfMonth @]
           *          when 'day_of_year' then @children = [new DayOfYear @]
           *          when 'offset_from_pascha' then @children = [new OffsetFromPascha @]
           */
            var klass;
            klass = _this.choices(e.target.value);
            _this.children = [new klass(_this)];
            _this.data.type = e.target.value;
            return _this.triggerRender();
          };
        })(this)
      );
      row = this.elem.find('div.row');
      children = Validation.__super__.render.apply(this, arguments).toArray();
      row.append(children.shift());
      this.elem.append(children);
      return this.elem;
    };

    return Validation;
  })(Option);

  /*
   * Validation Types
   * ================
   * we have a seperate class for each type of validation that the
   * user can pick with `Validation`.
   *
   * Validation Instance
   * -------------------
   * ValidationInstance is a base class for some of the simpler
   * validation types (typically those with a single parameter).
   */
  ValidationInstance = (function(superClass) {
    extend(ValidationInstance, superClass);

    function ValidationInstance() {
      return ValidationInstance.__super__.constructor.apply(this, arguments);
    }

    ValidationInstance.prototype.defaults = function() {
      return (this.data.value = this['default']);
    };

    ValidationInstance.prototype.fromData = function(d) {
      return (this.data.value = d);
    };

    ValidationInstance.prototype.getData = function() {
      return this.data.value;
    };

    /*
     * `dataTransformer` is what transforms the string representation
     * of the UI into a js datastructure. It is by default `parseInt`.
     */

    ValidationInstance.prototype.dataTransformer = parseInt;

    ValidationInstance.prototype['default'] = 1;

    /*
     * The `render` implementation relies on a `html` method that returns
     * an HTML string.
     */

    ValidationInstance.prototype.render = function() {
      var children, row;
      this.elem = $(this.html());
      this.elem.find('input,select').change(
        (function(_this) {
          return function(e) {
            return (_this.data.value = _this.dataTransformer(e.target.value));
          };
        })(this)
      );
      row = this.elem.find('div.row');
      children = ValidationInstance.__super__.render.apply(this, arguments).toArray();
      row.append(children.shift());
      return this.elem;
    };

    return ValidationInstance;
  })(Option);

  /*
   * Count
   * -----
   * Count will limit the maximum times an event can repeat.
   */
  Count = (function(superClass) {
    extend(Count, superClass);

    function Count() {
      return Count.__super__.constructor.apply(this, arguments);
    }

    Count.prototype.clonable = function() {
      return false;
    };

    Count.prototype.html = function() {
      return (
        '<div class="row">\n  <div class="col-md-2 label"><label></label></div>\n  <div class="Count col-md-8 small-padding">\n    <input type="number" value=' +
        this.data.value +
        ' /> times.\n  </div>\n  <div class="col-md-2 label"><label></label></div>\n</div>'
      );
    };

    return Count;
  })(ValidationInstance);

  /*
   * Until
   * -----
   * Until will repeat the event until a specified date.
   */
  Until = (function(superClass) {
    extend(Until, superClass);

    function Until() {
      return Until.__super__.constructor.apply(this, arguments);
    }

    Until.prototype.getData = function() {
      return this.data.time;
    };

    Until.prototype.clonable = function() {
      return false;
    };

    Until.prototype.destroyable = function() {
      return false;
    };

    return Until;
  })(DatePicker);

  /*
   * Hour of Day
   * ------------
   * Hour of day overwrites start time and allows for multiple occurrences during same day
   */
  HourOfDay = (function(superClass) {
    extend(HourOfDay, superClass);

    function HourOfDay() {
      return HourOfDay.__super__.constructor.apply(this, arguments);
    }

    HourOfDay.prototype.html = function() {
      var i, j, l, str;
      str =
        '<div class="HourOfDay">\n  <div class="row">\n    <div class="col-md-2 label"><label></label></div>\n    <div class="col-md-8 small-padding">\n      <select>';
      for (i = j = 0; j <= 11; i = ++j) {
        str += Helpers.option(i.toString(), (i === 0 ? 12 : i) + ' AM', this.data.value.toString());
      }
      for (i = l = 12; l <= 23; i = ++l) {
        str += Helpers.option(
          i.toString(),
          (i === 12 ? 12 : i - 12) + ' PM',
          this.data.value.toString()
        );
      }
      return (str += '</select> hour of day.\n    </div>\n  </div>\n</div>');
    };

    return HourOfDay;
  })(ValidationInstance);

  /*
   * Minute of hour
   * ------------
   * minute of hour overwrites start time and allows for multiple occurrences within an hour
   */
  MinuteOfHour = (function(superClass) {
    extend(MinuteOfHour, superClass);

    function MinuteOfHour() {
      return MinuteOfHour.__super__.constructor.apply(this, arguments);
    }

    MinuteOfHour.prototype.html = function() {
      var i, j, str;
      str =
        '<div class="HourOfDay">\n  <div class="row">\n    <div class="col-md-2 label"><label></label></div>\n    <div class="col-md-8 small-padding">\n      <select>';
      for (i = j = 0; j <= 59; i = ++j) {
        str += Helpers.option(i.toString(), '' + i, this.data.value.toString());
      }
      return (str += '</select> minute of hour.\n    </div>\n  </div>\n</div>');
    };

    return MinuteOfHour;
  })(ValidationInstance);

  /*
   * Day of Month
   * ------------
   * Day of month filters out days that are not the nth day of the month.
   */
  DayOfMonth = (function(superClass) {
    extend(DayOfMonth, superClass);

    function DayOfMonth() {
      return DayOfMonth.__super__.constructor.apply(this, arguments);
    }

    DayOfMonth.prototype.html = function() {
      var i, j, pluralize, str;
      pluralize = function(n) {
        switch (10 < n && n < 20 ? 4 : n % 10) {
          case 1:
            return 'st';
          case 2:
            return 'nd';
          case 3:
            return 'rd';
          default:
            return 'th';
        }
      };
      str =
        '<div class="DayOfMonth">\n  <div class="row">\n    <div class="col-md-2 label"><label></label></div>\n    <div class="col-md-8 small-padding">\n      <select>';
      for (i = j = 1; j <= 31; i = ++j) {
        str += Helpers.option(i.toString(), '' + i + pluralize(i), this.data.value.toString());
      }
      str += Helpers.option('-1', 'last', this.data.value.toString());
      return (str += '</select> day of the month.\n    </div>\n  </div>\n</div>');
    };

    return DayOfMonth;
  })(ValidationInstance);

  /*
   * Day
   * ---
   * Day let's the user filter events occuring on particular days of the
   * week.
   */
  Day = (function(superClass) {
    extend(Day, superClass);

    function Day() {
      return Day.__super__.constructor.apply(this, arguments);
    }

    Day.prototype.html = function() {
      var day, i, j, len, ref, str;
      str =
        '<div class="Day">\n  <div class="row">\n    <div class="col-md-2 label"><label></label></div>\n    <div class="col-md-8 small-padding">\n      <select>';
      ref = Helpers.daysOfTheWeek;
      for ((i = j = 0), (len = ref.length); j < len; i = ++j) {
        day = ref[i];
        str += Helpers.option(i.toString(), day, this.data.value.toString());
      }
      return (str += '      </select>\n    </div>\n  </div>\n</div>');
    };

    return Day;
  })(ValidationInstance);

  /*
   * Day of Week
   * -----------
   * This is the perhaps most confusing rule. It allows the user to
   * specify thing like "the 3rd sunday of the month" and so on.
   */
  DayOfWeek = (function(superClass) {
    extend(DayOfWeek, superClass);

    function DayOfWeek() {
      return DayOfWeek.__super__.constructor.apply(this, arguments);
    }

    DayOfWeek.prototype.getData = function() {
      return [this.data.day, this.data.nth];
    };

    DayOfWeek.prototype.fromData = function(data1) {
      this.data = data1;
    };

    DayOfWeek.prototype.defaults = function() {
      this.data.nth = 1;
      return (this.data.day = 0);
    };

    DayOfWeek.prototype.render = function() {
      var children, day, i, j, len, pluralize, ref, row, str;
      str =
        '<div class="DayOfWeek">\n  <div class="row">\n    <div class="col-md-2 label"><label><label></div>\n    <div class="col-md-4 small-padding">\n        <input type="number" value=' +
        this.data.nth +
        ' /><span>nth</span>.\n    </div>\n    <div class="col-md-4 small-padding">\n      <select>';
      ref = Helpers.daysOfTheWeek;
      for ((i = j = 0), (len = ref.length); j < len; i = ++j) {
        day = ref[i];
        str += Helpers.option(i.toString(), day, this.data.day.toString());
      }
      str += '</select> </div> </div> </div>';
      this.elem = $(str);
      pluralize = (function(_this) {
        return function() {
          return _this.elem.find('span').first().text(
            function() {
              switch (this.data.nth) {
                case 1:
                  return 'st';
                case 2:
                  return 'nd';
                case 3:
                  return 'rd';
                default:
                  return 'th';
              }
            }.call(_this)
          );
        };
      })(this);
      this.elem.find('input').change(
        (function(_this) {
          return function(e) {
            _this.data.nth = parseInt(e.target.value);
            return pluralize();
          };
        })(this)
      );
      this.elem.find('select').change(
        (function(_this) {
          return function(e) {
            return (_this.data.day = parseInt(e.target.value));
          };
        })(this)
      );
      row = this.elem.find('div.row');
      children = DayOfWeek.__super__.render.apply(this, arguments).toArray();
      row.append(children.shift());
      pluralize();
      return this.elem;
    };

    return DayOfWeek;
  })(Option);

  /*
   * Day of Year
   * -----------
   * Allows to specify a particular day of the year.
   */
  DayOfYear = (function(superClass) {
    extend(DayOfYear, superClass);

    function DayOfYear() {
      return DayOfYear.__super__.constructor.apply(this, arguments);
    }

    DayOfYear.prototype.getData = function() {
      return this.data.value;
    };

    DayOfYear.prototype.fromData = function(d) {
      return (this.data.value = d);
    };

    DayOfYear.prototype.defaults = function() {
      return (this.data.value = 1);
    };

    DayOfYear.prototype.render = function() {
      var children, row, str;
      str =
        '<div class="DayOfYear">\n  <div class="row">\n    <div class="col-md-2 label"><label><label></div>\n    <div class="col-md-4 small-padding">\n      <input type="number" value=' +
        Math.abs(this.data.value) +
        ' /> day from the\n    </div>\n    <div class="col-md-4 small-padding">\n      <select>\n        ' +
        Helpers.option(
          '+',
          'beginning',
          (function(_this) {
            return function() {
              return _this.data.value >= 0;
            };
          })(this)
        ) +
        '\n        ' +
        Helpers.option(
          '-',
          'end',
          (function(_this) {
            return function() {
              return _this.data.value < 0;
            };
          })(this)
        ) +
        '\n      </select> of the year.\n    </div>\n  </div>\n</div>';
      this.elem = $(str);
      this.elem.find('input,select').change(
        (function(_this) {
          return function(e) {
            _this.data.value = parseInt(_this.elem.find('input').val());
            return (_this.data.value *= _this.elem.find('select').val() === '+' ? 1 : -1);
          };
        })(this)
      );
      row = this.elem.find('div.row');
      children = DayOfYear.__super__.render.apply(this, arguments).toArray();
      row.append(children.shift());
      return this.elem;
    };

    return DayOfYear;
  })(Option);

  /*
   * Offset from Pascha
   * ------------------
   * This class allows the user to specify dates in relation to the
   * Orthodox celebration of Easter, Pascha.
   */
  OffsetFromPascha = (function(superClass) {
    extend(OffsetFromPascha, superClass);

    function OffsetFromPascha() {
      return OffsetFromPascha.__super__.constructor.apply(this, arguments);
    }

    OffsetFromPascha.prototype.getData = function() {
      return this.data.value;
    };

    OffsetFromPascha.prototype.defaults = function() {
      return (this.data.value = 0);
    };

    OffsetFromPascha.prototype.fromData = function(d) {
      return (this.data.value = d);
    };

    OffsetFromPascha.prototype.render = function() {
      var children, row, str;
      str =
        '<div class="OffsetFromPascha">\n  <div class="row">\n    <div class="col-md-2 label"><label><label></div>\n    <div class="col-md-4 small-padding">\n      <input type="number" value=' +
        Math.abs(this.data.value) +
        ' /> days\n    </div>\n    <div class="col-md-4 small-padding">\n      <select>\n        ' +
        Helpers.option(
          '+',
          'after',
          (function(_this) {
            return function() {
              return _this.data.value >= 0;
            };
          })(this)
        ) +
        '\n        ' +
        Helpers.option(
          '-',
          'before',
          (function(_this) {
            return function() {
              return _this.data.value < 0;
            };
          })(this)
        ) +
        '\n      </select> Pascha.\n    </div>\n  </div>\n</div>';
      this.elem = $(str);
      this.elem.find('input,select').change(
        (function(_this) {
          return function(e) {
            _this.data.value = parseInt(_this.elem.find('input').val());
            return (_this.data.value *= _this.elem.find('select').val() === '+' ? 1 : -1);
          };
        })(this)
      );
      row = this.elem.find('div.row');
      children = OffsetFromPascha.__super__.render.apply(this, arguments).toArray();
      row.append(children.shift());
      return this.elem;
    };

    return OffsetFromPascha;
  })(Option);

  /*
   * ICUI
   * ----
   * This is the class that is responsible for initializing the whole
   * hierarchy and also setting up the form to retrieve the correct
   * representation.
   */
  ICUI = (function() {
    function ICUI($el, opts) {
      var advanced_schedule,
        advanced_schedule_radio,
        between_hours,
        container,
        data,
        e,
        hours_input,
        simple_schedule,
        simple_schedule_radio;
      container = $el.closest('div[data-schedule-wrapper]');
      simple_schedule = container.find('div[data-simple-schedule]');
      advanced_schedule = container.find('div[data-advanced-schedule]');
      simple_schedule_radio = simple_schedule.find('input[data-simple-schedule-radio]');
      advanced_schedule_radio = advanced_schedule.find('input[data-simple-schedule-radio]');
      between_hours = container.find('[data-between-hours]');
      hours_input = container.find('input[data-hours]');
      if (parseInt(hours_input.val(), 10) > 0) {
        between_hours.show();
      } else {
        between_hours.hide();
      }
      container.find('a[data-toggler]').on('click', function(event) {
        event.preventDefault();
        simple_schedule_radio.prop('checked', !simple_schedule_radio.prop('checked'));
        advanced_schedule_radio.prop('checked', !simple_schedule_radio.prop('checked'));
        advanced_schedule.toggle();
        return simple_schedule.toggle();
      });
      hours_input.on('blur', function(event) {
        if (parseInt($(event.target).val(), 10) > 0) {
          return between_hours.show();
        } else {
          return between_hours.hide();
        }
      });
      data = (function() {
        try {
          return JSON.parse($el.val());
        } catch (error) {
          e = error;
          return null;
        }
      })();
      this.root = new Root($el, data);
      $el.parents('form').on(
        'submit',
        (function(_this) {
          return function(e) {
            if (opts['submit']) {
              opts.submit(_this.getData());
              e.preventDefault();
              return false;
            } else {
              return $el.val(JSON.stringify(_this.getData()));
            }
          };
        })(this)
      );
      $el.after(this.root.render());
    }

    ICUI.prototype.getData = function() {
      return this.root.getData();
    };

    return ICUI;
  })();

  /*
   * The jQuery Plugin
   * -----------------
   * Aceepts an options object where future configuration can go in.
   * Currently suports only a 'submit' key, which is a function called
   * on submitting the form.
   */
  return ($.fn.icui = function(opts) {
    if (opts == null) {
      opts = {};
    }
    return this.each(function() {
      return new ICUI($(this), opts);
    });
  });
})(jQuery);
