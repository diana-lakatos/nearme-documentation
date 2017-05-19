var Schedule,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

Schedule = function() {
  function Schedule(el) {
    this.initializeNewRow = bind(this.initializeNewRow, this);
    this.container = $(el);
    this.bindEvents();
    this.initModeContainers(this.container);
  }

  Schedule.prototype.initModeContainers = function(context) {
    return $(context).find('[data-pricing-run-mode]').each(
      function(_this) {
        return function(index, item) {
          var container, mode;
          container = $(item);
          mode = container.find('[data-pricing-run-mode-selector]').val();
          return _this.setMode(container, mode);
        };
      }(this)
    );
  };

  Schedule.prototype.bindEvents = function() {
    /*
     * run mode selector changed
     */
    this.container.on(
      'change',
      '[data-pricing-run-mode-selector]',
      function(_this) {
        return function(e) {
          var container, mode;
          container = $(e.target).closest('[data-pricing-run-mode]');
          mode = $(e.target).closest('select').val();
          return _this.setMode(container, mode);
        };
      }(this)
    );

    /*
     * add single time field
     */
    this.container.on(
      'click',
      '[data-add-datetime]',
      function(_this) {
        return function(e) {
          /*
         * control-group selector is a legacy selector for UI prior to 2015-12.
         * It should be removed after instance admin has been updated to newer version
         */
          var anchor, template;
          template = $(e.target)
            .closest('.form-group, .control-group')
            .find('.removable-field:last');
          anchor = $(e.target).closest('.add-entry');
          return _this.addTime(template, anchor);
        };
      }(this)
    );

    /*
     * remove single time field
     */
    this.container.on(
      'click',
      '[data-remove-datetime]',
      function(_this) {
        return function(e) {
          var field;
          field = $(e.target).closest('.removable-field');
          return _this.removeTime(field);
        };
      }(this)
    );
    return this.container.on(
      'cocoon:after-insert',
      function(_this) {
        return function(e, insertedItem) {
          return _this.initializeNewRow(insertedItem);
        };
      }(this)
    );
  };

  Schedule.prototype.setMode = function(container, mode) {
    this.modes = container.find('.run-mode');
    this.modes.addClass('hidden').attr('aria-hidden', true);
    if (!mode) {
      return;
    }
    return this.modes.filter('.' + mode).removeClass('hidden').removeAttr('aria-hidden');
  };

  Schedule.prototype.addTime = function(template, anchor) {
    var field, input;
    field = $(template).clone(false);
    input = field.find('input');
    input.val('');
    input.attr('name', anchor.data('input-name'));
    anchor.before(field);
    $('html').trigger('datepickers.init.forms', [ field ]);
    return $('html').trigger('timepickers.init.forms', [ field ]);
  };

  Schedule.prototype.removeTime = function(field) {
    /*
     * control-group selector is a legacy selector for UI prior to 2015-12.
     * It should be removed after instance admin has been updated to newer version
     */
    if (field.closest('.form-group, .control-group').find('.removable-field').length < 2) {
      return alert('You cannot remove the only time field');
    }
    return field.remove();
  };

  Schedule.prototype.initializeNewRow = function(insertedItem) {
    this.initModeContainers(insertedItem);
    $('html').trigger('datepickers.init.forms', [ insertedItem ]);
    $('html').trigger('timepickers.init.forms', [ insertedItem ]);
    return $('html').trigger('selects.init.forms', [ insertedItem ]);
  };

  return Schedule;
}();

module.exports = Schedule;
