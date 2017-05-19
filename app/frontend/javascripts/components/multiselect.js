var Multiselect;

Multiselect = function() {
  function Multiselect(element) {
    this.element = $(element);
    this.element.data('multiselect', this);
    this.collapsedContainer = this.element.find('.collapsed');
    this.expandedContainer = this.element.find('.expanded');
    this.expandedSummary = this.expandedContainer.find('.summary');

    /*
     * Disable selection
     */
    this.element.attr('unselectable', 'on').css('user-select', 'none').on('selectstart', false);

    /*
     * Setup initial state
     */
    this.updateValues();
    this.bindEvents();
  }

  Multiselect.prototype.bindEvents = function() {
    this.expandedContainer.on(
      'click',
      'input[type="checkbox"]',
      function(_this) {
        return function(event) {
          return _this.itemSelectionChanged($(event.target));
        };
      }(this)
    );
    this.collapsedContainer.on(
      'click',
      function(_this) {
        return function() {
          return _this.open();
        };
      }(this)
    );
    this.expandedSummary.on(
      'click',
      function(_this) {
        return function() {
          return _this.close();
        };
      }(this)
    );
    return $('body').on(
      'click',
      function(_this) {
        return function(event) {
          /*
         * Close if we've clicked on an element that isn't a descendant of the multiselect
         */
          if (_this.isOpen && $(event.target).closest(_this.element).length === 0) {
            return _this.close();
          }
        };
      }(this)
    );
  };

  Multiselect.prototype.itemSelectionChanged = function(item) {
    var $item;
    $item = $(item);
    $item.closest('.item').toggleClass('checked', $item.is(':checked'));
    return this.updateCount();
  };

  Multiselect.prototype.open = function() {
    /*
    #@collapsedContainer.hide()
     */
    this.expandedContainer.show().toggleClass('long', this.items.length > 8);
    return this.isOpen = true;
  };

  Multiselect.prototype.items = function() {
    return this.expandedContainer.find('input[type="checkbox"]:checked');
  };

  Multiselect.prototype.close = function() {
    this.expandedContainer.hide();

    /*
    #@collapsedContainer.show()
     */
    return this.isOpen = false;
  };

  Multiselect.prototype.updateValues = function() {
    var selected;
    selected = this.expandedContainer.find('input[type="checkbox"]:checked');
    selected.closest('.item').addClass('checked');
    return this.updateCount(selected.length);
  };

  Multiselect.prototype.updateCount = function(newCount) {
    var text;
    if (newCount == null) {
      newCount = this.items().length;
    }
    text = newCount === 0 ? 'Amenities' : 'Amenities';
    this.collapsedContainer.text(text);
    return this.expandedSummary.text(text);
  };

  return Multiselect;
}();

module.exports = Multiselect;
