var InstanceAdminRootCategoriesController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

InstanceAdminRootCategoriesController = function() {
  function InstanceAdminRootCategoriesController(container) {
    this.container = container;
    this.setupSortable = bind(this.setupSortable, this);
    this.setupSortable();
  }

  InstanceAdminRootCategoriesController.prototype.setupSortable = function() {
    return this.container.sortable({
      update: function() {
        var data;
        data = $(this).sortable('serialize');
        return $.ajax({
          data: data,
          type: 'PUT',
          url: '/instance_admin/manage/categories_positions'
        });
      }
    });
  };

  return InstanceAdminRootCategoriesController;
}();

module.exports = InstanceAdminRootCategoriesController;
