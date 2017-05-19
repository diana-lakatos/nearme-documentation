var InstanceAdminCategoriesController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('../../../vendor/jquery.jstree');

InstanceAdminCategoriesController = function() {
  function InstanceAdminCategoriesController(container) {
    this.container = container;
    this.handleDelete = bind(this.handleDelete, this);
    this.handleRename = bind(this.handleRename, this);
    this.handleCreate = bind(this.handleCreate, this);
    this.handleMove = bind(this.handleMove, this);
    this.handleAjaxError = bind(this.handleAjaxError, this);
    this.setupCategoriesTree = bind(this.setupCategoriesTree, this);
    this.category_id = this.container.data('category-id');
    if (!this.category_id) {
      return;
    }
    this.categories_path = this.container.data('category-path');
    this.setupCategoriesTree();
    this.last_rollback = null;
  }

  InstanceAdminCategoriesController.prototype.getCategoriesPath = function() {
    return this.categories_path;
  };

  InstanceAdminCategoriesController.prototype.setupCategoriesTree = function() {
    var categories_path, that;
    if (this.container.find('#category_tree').length > 0) {
      categories_path = this.getCategoriesPath();
      that = this;
      $.ajax({
        url: (categories_path + '/' + this.category_id + '/jstree?root=true').toString(),
        success: function(_this) {
          return function(category) {
            var conf;
            _this.last_rollback = null;
            conf = {
              json_data: {
                data: category,
                ajax: {
                  url: function(e) {
                    return (categories_path + '/' + e.prop('id') + '/jstree').toString();
                  }
                }
              },
              themes: { theme: 'apple', url: false },
              strings: { new_node: 'New category', loading: 'Loading ...' },
              crrm: {
                move: {
                  check_move: function(m) {
                    var new_parent, node, position;
                    position = m.cp;
                    node = m.o;
                    new_parent = m.np;

                    /*
                     * no parent or cant drag and drop
                     */
                    if (!new_parent || node.prop('rel') === 'root') {
                      return false;
                    }

                    /*
                     * can't drop before root
                     */
                    if (new_parent.prop('id') === 'category_tree' && position === 0) {
                      return false;
                    }
                    return true;
                  }
                }
              },
              contextmenu: {
                items: function(obj) {
                  return that.categoryTreeMenu(obj, this);
                }
              },
              plugins: [ 'themes', 'json_data', 'dnd', 'crrm', 'contextmenu' ]
            };
            return $('#category_tree')
              .jstree(conf)
              .bind('move_node.jstree', _this.handleMove)
              .bind('remove.jstree', _this.handleDelete)
              .bind('create.jstree', _this.handleCreate)
              .bind('rename.jstree', _this.handleRename)
              .bind('loaded.jstree', function() {
                return $(this).jstree('core').toggle_node($('.jstree-icon').first());
              });
          };
        }(this)
      });
      $('#category_tree a').on('dblclick', function() {
        return $('#category_tree').jstree('rename', this);
      });

      /*
       * surpress form submit on enter/return
       */
      return $(document).keypress(function(e) {
        if (e.keyCode === 13) {
          return e.preventDefault();
        }
      });
    }
  };

  InstanceAdminCategoriesController.prototype.handleAjaxError = function(
    XMLHttpRequest,
    textStatus,
    errorThrown
  ) {
    $.jstree.rollback(this.last_rollback);
    $('#ajax_error')
      .show()
      .html(
        '<strong>The server returned an error</strong><br />The requested change has not been accepted and the tree has been returned to its previous state, please try again'
      );
    if (window.Raygun) {
      return window.Raygun.send(errorThrown, textStatus);
    }
  };

  InstanceAdminCategoriesController.prototype.handleMove = function(e, data) {
    var new_parent, node, position, url;
    this.last_rollback = data.rlbk;
    position = data.rslt.cp;
    node = data.rslt.o;
    new_parent = data.rslt.np;
    url = this.getCategoriesPath() + '/' + node.prop('id');
    $.ajax({
      type: 'POST',
      dataType: 'json',
      url: url.toString(),
      data: {
        _method: 'put',
        'category[parent_id]': new_parent.prop('id'),
        'category[child_index]': position
      },
      error: this.handleAjaxError
    });
    return true;
  };

  InstanceAdminCategoriesController.prototype.handleCreate = function(e, data) {
    var name, new_parent, node, position;
    this.last_rollback = data.rlbk;
    node = data.rslt.obj;
    name = data.rslt.name;
    position = data.rslt.position;
    new_parent = data.rslt.parent;
    return $.ajax({
      type: 'POST',
      dataType: 'json',
      url: this.getCategoriesPath(),
      data: {
        'category[name]': name,
        'category[parent_id]': new_parent.prop('id'),
        'category[child_index]': position
      },
      error: this.handleAjaxError,
      success: function(data) {
        return node.prop('id', data.id);
      }
    });
  };

  InstanceAdminCategoriesController.prototype.handleRename = function(e, data) {
    var name, node, url;
    this.last_rollback = data.rlbk;
    node = data.rslt.obj;
    name = data.rslt.new_name;
    url = this.getCategoriesPath() + '/' + node.prop('id');
    return $.ajax({
      type: 'POST',
      dataType: 'json',
      url: url.toString(),
      data: { _method: 'put', 'category[name]': name },
      success: function(data) {
        if (data && data.message) {
          return alert(data.message);
        }
      },
      error: this.handleAjaxError
    });
  };

  InstanceAdminCategoriesController.prototype.handleDelete = function(e, data) {
    var delete_url, node;
    this.last_rollback = data.rlbk;
    node = data.rslt.obj;
    delete_url = this.getCategoriesPath() + '/' + node.prop('id');
    if (confirm('Are you sure you want to remove this category?')) {
      return $.ajax({
        type: 'POST',
        dataType: 'json',
        url: delete_url.toString(),
        data: { _method: 'delete' },
        error: this.handleAjaxError
      });
    } else {
      $.jstree.rollback(this.last_rollback);
      return this.last_rollback = null;
    }
  };

  InstanceAdminCategoriesController.prototype.categoryTreeMenu = function(obj, context) {
    var actions;
    actions = {
      create: {
        label: "<i class='fa fa-plus'></i> Add",
        action: function(obj) {
          return context.create(obj);
        }
      }
    };
    if (obj.attr('is_root') !== 'true') {
      actions.rename = {
        label: "<i class='fa fa-pencil'></i> Rename",
        action: function(obj) {
          return context.rename(obj);
        }
      };
      actions.remove = {
        label: "<i class='fa fa-trash-o'></i> Remove",
        action: function(obj) {
          return context.remove(obj);
        }
      };
    }
    return actions;
  };

  return InstanceAdminCategoriesController;
}();

module.exports = InstanceAdminCategoriesController;
