var CategoryAutocompleteInput,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('selectize/dist/js/selectize');

CategoryAutocompleteInput = function() {
  function CategoryAutocompleteInput(el) {
    this.update = bind(this.update, this);
    this.input = $(el);
    this.categoryId = this.input.data('category-id');
    this.attrName = this.input.attr('name') + '[]';
    this.input.removeAttr('name');
    this.build();
    this.initialize();
    this.update();
  }

  CategoryAutocompleteInput.prototype.build = function() {
    this.valueInputsContainer = $('<div class="value-inputs"/>');
    return this.input.after(this.valueInputsContainer);
  };

  CategoryAutocompleteInput.prototype.initialize = function() {
    return this.input.selectize({
      create: false,
      valueField: 'id',
      labelField: 'name',
      searchField: 'name',
      options: this.input.data('items'),
      load: function(_this) {
        return function(query, callback) {
          if (!query.length) {
            return callback();
          }
          return $.ajax({
            url: _this.input.data('api'),
            type: 'GET',
            dataType: 'json',
            data: { q: { name_cont: query } },
            error: function() {
              return callback();
            },
            success: function(res) {
              return callback(res);
            }
          });
        };
      }(this),
      onChange: this.update
    });
  };

  CategoryAutocompleteInput.prototype.update = function() {
    var ids;
    ids = this.input.get(0).selectize.getValue().split(',');
    this.valueInputsContainer.empty();
    return $.each(
      ids,
      function(_this) {
        return function(index, id) {
          return _this.valueInputsContainer.append(
            "<input type='hidden' name='" + _this.attrName + "' value='" + id + "'>"
          );
        };
      }(this)
    );
  };

  return CategoryAutocompleteInput;
}();

module.exports = CategoryAutocompleteInput;
