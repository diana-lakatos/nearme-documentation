var OrderItemsIndex;

OrderItemsIndex = function() {
  function OrderItemsIndex(context) {
    if (context == null) {
      context = 'body';
    }
    this.transactableSelect = $(context);
    if (this.transactableSelect.find('option:selected').length > 0) {
      $('#transactable_' + this.transactableSelect.find('option:selected').val()).show();
    } else {
      $('.panel:first').show();
    }
    this.bindEvents();
  }

  OrderItemsIndex.prototype.bindEvents = function() {
    return this.transactableSelect.on('change', function(e) {
      $('.panel').hide();
      return $('#transactable_' + $(e.target).val()).show();
    });
  };

  return OrderItemsIndex;
}();

module.exports = OrderItemsIndex;
