var InstanceAdminAdminRolesController;

InstanceAdminAdminRolesController = function() {
  function InstanceAdminAdminRolesController(container, options) {
    this.container = container;
    this.options = options != null ? options : {};
    this.permissionCheckboxes = this.container.find('input[data-permission-checkbox]');
    this.bindEvents();
  }

  InstanceAdminAdminRolesController.prototype.bindEvents = function() {
    return this.permissionCheckboxes.on(
      'change',
      function(_this) {
        return function(event) {
          var str;
          str = '{"instance_admin_role": {"' + $(event.target).data('permission-checkbox') +
            '": "' +
            $(event.target).is(':checked') +
            '"}}';
          _this.loading_gif = $(event.target).siblings('[data-loading]').eq(0);
          _this.loading_gif.show();
          return $.ajax({
            type: 'PUT',
            url: '/instance_admin/manage/admins/instance_admin_roles/' +
              $(event.target).data('role-id'),
            data: JSON.parse(str),
            success: function() {
              return _this.loading_gif.hide();
            }
          });
        };
      }(this)
    );
  };

  return InstanceAdminAdminRolesController;
}();

module.exports = InstanceAdminAdminRolesController;
