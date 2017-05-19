var InstanceAdminAdminsController;

InstanceAdminAdminsController = function() {
  function InstanceAdminAdminsController(container, options) {
    this.container = container;
    this.options = options != null ? options : {};
    this.roleSelects = this.container.find('select[data-role-select]');
    this.bindEvents();
  }

  InstanceAdminAdminsController.prototype.bindEvents = function() {
    return this.roleSelects.on(
      'change',
      function(_this) {
        return function(event) {
          _this.loading_gif = $(event.target).siblings('[data-loading]').eq(0);
          _this.loading_gif.show();
          return $.ajax({
            type: 'PUT',
            url: '/instance_admin/manage/admins/instance_admins/' +
              $(event.target).data('instance-admin-id'),
            data: { instance_admin_role_id: $(event.target).val() },
            success: function() {
              return _this.loading_gif.hide();
            }
          });
        };
      }(this)
    );
  };

  return InstanceAdminAdminsController;
}();

module.exports = InstanceAdminAdminsController;
