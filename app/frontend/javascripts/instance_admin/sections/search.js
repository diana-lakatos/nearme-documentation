var InstanceAdminSearchSettings;

InstanceAdminSearchSettings = function() {
  function InstanceAdminSearchSettings() {
    this.bindEvents();
  }

  InstanceAdminSearchSettings.prototype.bindEvents = function() {
    return $(
      'ul.sortable'
    ).sortable({ axis: 'y', cursor: 'move', stop: this.updateIndex, opacity: 0.7 });
  };

  InstanceAdminSearchSettings.prototype.updateIndex = function(e, ui) {
    return $.ajax({
      type: 'PUT',
      url: ui.item.closest('ul').data('update-url'),
      data: { transactable_types: $(e.target).sortable('toArray') }
    });
  };

  return InstanceAdminSearchSettings;
}();

module.exports = InstanceAdminSearchSettings;
