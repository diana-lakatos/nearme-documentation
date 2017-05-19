var CategoryTreeInput,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('jstree/dist/jstree.min');

CategoryTreeInput = function() {
  function CategoryTreeInput(el) {
    this.initTree = bind(this.initTree, this);
    this.initialize = bind(this.initialize, this);
    this.container = $(el);
    this.input = this.container.find('[data-category-id]');
    this.categoryId = this.input.data('category-id');
    this.apiUrl = this.input.data('category-api-url');
    this.isMultiple = !!this.input.data('category-multiple-choice');
    this.selectedCategories = (this.input.data('value') + '').split(',');
    this.attrName = this.input.attr('name') + '[]';
    this.input.remove();
    this.build();
    this.initialize();
  }

  CategoryTreeInput.prototype.build = function() {
    this.treeContainer = $('<div class="tree-container"/>');
    this.valueInputsContainer = $('<div class="value-inputs"/>');
    return this.container.append(this.treeContainer, this.valueInputsContainer);
  };

  CategoryTreeInput.prototype.initialize = function() {
    return $.ajax({
      url: this.apiUrl,
      data: { category_ids: this.selectedCategories },
      success: this.initTree
    });
  };

  CategoryTreeInput.prototype.initTree = function(data) {
    var conf;
    conf = {
      core: { data: data.categories, themes: { name: 'default', icons: false } },
      plugins: [ 'checkbox' ],
      checkbox: { three_state: false, tie_selection: false }
    };
    this.treeContainer.jstree(conf);
    this.treeContainer.bind(
      'loaded.jstree',
      function(_this) {
        return function(e, data) {
          return _this.update(data.instance.get_checked());
        };
      }(this)
    );
    this.treeContainer.on(
      'check_node.jstree',
      function(_this) {
        return function(e, data) {
          var currentId, parentIds;
          data.instance.open_node(data.node);
          if (!_this.isMultiple) {
            currentId = data.node.id;
            parentIds = data.node.parents;
            $.each(data.instance.get_checked(true), function(index, item) {
              if (currentId === item.id || $.inArray(item.id, parentIds) > -1) {
                return;
              }
              data.instance.uncheck_node(item.id);
              return data.instance.uncheck_node(item.children_d);
            });
          }
          return _this.update(data.instance.get_checked());
        };
      }(this)
    );
    return this.treeContainer.on(
      'uncheck_node.jstree',
      function(_this) {
        return function(e, data) {
          data.instance.close_all(data.node);
          data.instance.uncheck_node(data.node.children_d);
          return _this.update(data.instance.get_checked());
        };
      }(this)
    );
  };

  CategoryTreeInput.prototype.update = function(ids) {
    ids = this.treeContainer.jstree('get_checked');
    ids = _.uniq(ids);
    this.valueInputsContainer.empty();
    if (ids.length > 0) {
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
    } else {
      return this.valueInputsContainer.append(
        "<input type='hidden' name='" + this.attrName + "' value=''>"
      );
    }
  };

  return CategoryTreeInput;
}();

module.exports = CategoryTreeInput;
