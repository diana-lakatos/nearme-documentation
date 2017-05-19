var Limiter;

require('../../vendor/jquery.limiter');

Limiter = function() {
  function Limiter(el) {
    this.el = $(el);
    this.intialize();
  }

  Limiter.prototype.intialize = function() {
    return this.el.each(function() {
      var el, limit, target;
      el = $(this);
      limit = parseInt(el.data('counter-limit'));
      target = $('[data-counter-for="' + el.attr('id') + '"]');
      return el.limiter(limit, target);
    });
  };

  return Limiter;
}();

module.exports = Limiter;
