var FormComponents;

FormComponents = function() {
  function FormComponents(sortable_container) {
    this.sortable_container = sortable_container;
    this.initial_path = this.sortable_container.data('initial-path');
    this.bindEvents();
  }

  FormComponents.prototype.bindEvents = function() {
    return $(this.sortable_container).sortable({
      axis: 'y',
      cursor: 'move',
      update: function(_this) {
        return function(event, ui) {
          var id, index;
          id = ui.item.data('id');
          index = ui.item.index();
          return $.ajax({
            data: { '_method': 'patch', 'rank_position': index },
            type: 'POST',
            dataType: 'json',
            url: _this.initial_path + ('/' + id + '/update_rank'),
            complete: function() {
              return ui.item.find('.panel-heading').effect('highlight', {}, 2000);
            }
          });
        };
      }(this)
    });
  };

  return FormComponents;
}();

module.exports = FormComponents;
