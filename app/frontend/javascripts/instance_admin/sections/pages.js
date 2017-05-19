var InstanceAdminPagesController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

InstanceAdminPagesController = function() {
  function InstanceAdminPagesController(container) {
    this.container = container;
    this.updateIndex = bind(this.updateIndex, this);
    this.bindEvents = bind(this.bindEvents, this);
    /*
     * For now we do not want to allow pages sorting
     * @bindEvents()
     */
  }

  InstanceAdminPagesController.prototype.bindEvents = function() {
    return this.container
      .find('tbody')
      .sortable({ stop: this.updateIndex, helper: this.fixTableRowWidths });
  };

  InstanceAdminPagesController.prototype.updateIndex = function(e, ui) {
    return $.ajax({
      type: 'PUT',
      url: ui.item.find('td a').first().attr('href'),
      dataType: 'JSON',
      data: { page: { position_position: this.container.find('tbody tr').index(ui.item) } }
    });
  };

  InstanceAdminPagesController.prototype.fixTableRowWidths = function(e, tr) {
    var helper, originals;
    originals = tr.children();
    helper = tr.clone();
    helper.children().each(function(index) {
      return $(this).width(originals.eq(index).width());
    });
    return helper;
  };

  return InstanceAdminPagesController;
}();

module.exports = InstanceAdminPagesController;
