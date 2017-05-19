var PriceRange;

require('nouislider/distribute/jquery.nouislider.all');

PriceRange = function() {
  function PriceRange(element, max, parent) {
    var values;
    this.element = $(element);
    this.parent = parent;
    this.max = max;
    this.slider = this.element.find('.slider');
    if (!(this.slider.length > 0)) {
      return;
    }
    values = this.element.find('input').map(function(k, el) {
      return el['value'];
    });
    this.slider.slider({
      range: true,
      values: [ values[0], values[1] ],
      min: 0,
      max: this.max,
      step: 25,
      slide: function(_this) {
        return function(event, ui) {
          return _this.onChange(ui.values);
        };
      }(this)
    });
    this.updateValue(values[0], values[1]);
  }

  PriceRange.prototype.updateValue = function(min, max) {
    if (parseInt(max) === this.max) {
      max = this.max + '+';
    }
    return this.element.find('.value').text('$' + min + ' - $' + max + '/day');
  };

  PriceRange.prototype.onChange = function(values) {
    this.element.find('input[name*=min]').val(values[0]);
    this.element.find('input[name*=max]').val(values[1]);
    this.updateValue(values[0], values[1]);
    return this.parent.fieldChanged('priceRange', values);
  };

  return PriceRange;
}();

module.exports = PriceRange;
