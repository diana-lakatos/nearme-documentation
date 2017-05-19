var BookingType,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

BookingType = function() {
  function BookingType(el) {
    this.bindEvents = bind(this.bindEvents, this);
    this.container = $(el);
    this.tabs = this.container.find('[data-toggle="tab"]');
    this.bindEvents();
  }

  BookingType.prototype.bindEvents = function() {
    return this.tabs.on('show.bs.tab', function(e) {
      $("input[data-action][data-action!='" + $(e.target).attr('href') + "']").val('false');
      return $("input[data-action][data-action='" + $(e.target).attr('href') + "']").val('true');
    });
  };

  return BookingType;
}();

module.exports = BookingType;
