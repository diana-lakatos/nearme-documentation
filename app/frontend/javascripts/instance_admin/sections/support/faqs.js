var InstanceAdminFaqsController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

InstanceAdminFaqsController = function() {
  function InstanceAdminFaqsController(container) {
    this.container = container;
    this.updateIndex = bind(this.updateIndex, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.bindEvents();
  }

  InstanceAdminFaqsController.prototype.bindEvents = function() {
    return this.container
      .find('tbody')
      .sortable({ stop: this.updateIndex, helper: this.fixTableRowWidths });
  };

  InstanceAdminFaqsController.prototype.updateIndex = function(e, ui) {
    return $.ajax({
      type: 'PUT',
      url: ui.item.find('td a').last().attr('href'),
      dataType: 'JSON',
      data: { support_faq: { position: this.container.find('tbody tr').index(ui.item) } }
    });
  };

  InstanceAdminFaqsController.prototype.fixTableRowWidths = function(e, tr) {
    var helper, originals;
    originals = tr.children();
    helper = tr.clone();
    helper.children().each(function(index) {
      return $(this).width(originals.eq(index).width());
    });
    return helper;
  };

  return InstanceAdminFaqsController;
}();

module.exports = InstanceAdminFaqsController;
