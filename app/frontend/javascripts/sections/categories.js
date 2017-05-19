var CategoriesController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('select2/select2');

require('../../vendor/jquery.jstree');

CategoriesController = function() {
  function CategoriesController(container) {
    this.container = container;
    this.handleAjaxError = bind(this.handleAjaxError, this);
    this.setupCategoriesTreeFor = bind(this.setupCategoriesTreeFor, this);
    this.setupCategoriesTrees = bind(this.setupCategoriesTrees, this);
    this.setupCategoriesTrees();
    this.autocomplete();
    this.last_rollback = null;
  }

  CategoriesController.prototype.setupCategoriesTrees = function() {
    var i, j, len, ref, results, tree_container;
    if (this.container.find('.tree_container').length > 0) {
      ref = this.container.find('.tree_container');
      results = [];
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        tree_container = ref[i];
        results.push(this.setupCategoriesTreeFor($(tree_container)));
      }
      return results;
    }
  };

  CategoriesController.prototype.setupCategoriesTreeFor = function(tree_container) {
    var category_id, category_tree, selected_categories, selected_category_ids, that;
    that = this;
    category_id = tree_container.attr('data-category-id');
    category_tree = tree_container.find('.category_tree');
    if (category_tree.length > 0) {
      selected_category_ids = tree_container
        .find('.category_ids:not([data-value=""])')
        .eq(0)
        .attr('data-value');
      selected_categories = selected_category_ids === void 0
        ? []
        : selected_category_ids.split(',');
      return $.ajax({
        url: '/dashboard/api/categories/' + category_id + '/tree',
        data: { category_ids: selected_categories, category_id: category_id },
        success: function(category) {
          var conf;
          that.last_rollback = null;
          conf = {
            json_data: {
              data: category,
              ajax: {
                url: function(e) {
                  return '/dashboard/api/categories/' + e.prop('id') + '/tree';
                },
                data: { category_ids: selected_categories }
              }
            },
            themes: { theme: 'apple', url: false },
            strings: { new_node: 'New category', loading: 'Loading ...' },
            plugins: [ 'themes', 'json_data', 'checkbox', 'real_checkboxes' ],
            checkbox: {
              real_checkboxes: false,
              three_state: false,
              tie_selection: false,
              cascade: 'up',
              two_state: true
            }
          };
          return category_tree.jstree(conf).bind('loaded.jstree', function() {
            var i, j, len, results;
            that.bindClickEvent(category_tree);
            selected_categories = conf.json_data.ajax.data.category_ids;
            if (selected_categories.length > 0) {
              $.jstree
                ._reference(category_tree)
                .open_all(category_tree.jstree('get_checked', null, true));
              results = [];
              for (i = j = 0, len = selected_categories.length; j < len; i = ++j) {
                category_id = selected_categories[i];
                category_tree.jstree('check_node', $('#' + category_id));
                results.push(category_tree.jstree('open_node', $('#' + category_id)));
              }
              return results;
            }
          }).bind('check_node.jstree uncheck_node.jstree ', function() {
            return that.setChecboxesValues(tree_container);
          }).bind('check_node.jstree', function(e, data) {
            var currentNode;
            if (
              tree_container.find('.single_choice_category').val() === 'false' &&
                data.rslt.obj.attr('root') === 'true'
            ) {
              currentNode = data.rslt.obj.attr('id');
              category_tree.jstree('get_checked', null, true).each(function() {
                if (currentNode !== this.id && $(this).attr('root') === 'true') {
                  $.jstree._reference(category_tree).uncheck_node('#' + this.id);
                }
              });
            }
          }).bind('after_open.jstree', function() {
            that.bindClickEvent(category_tree);
            return that.setChecboxesValues(tree_container);
          }).bind('after_close.jstree', function() {
            return that.setChecboxesValues(tree_container);
          }).bind('check_node.jstree', function(e, data) {
            return data.inst.open_node(data.rslt.obj, true);
          }).bind('uncheck_node.jstree', function(e, data) {
            data.inst.close_all(data.rslt.obj, true);
            return data.rslt.obj
              .find('li.jstree-checked')
              .removeClass('jstree-checked')
              .addClass('jstree-unchecked');
          });
        }
      });
    }
  };

  CategoriesController.prototype.bindClickEvent = function(category_tree) {
    category_tree.find('a').unbind('click');
    return category_tree.find('a').on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      if (category_tree.jstree('is_checked', this)) {
        return category_tree.jstree('uncheck_node', this);
      } else {
        return category_tree.jstree('check_node', this);
      }
    });
  };

  CategoriesController.prototype.handleAjaxError = function(
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

  CategoriesController.prototype.setChecboxesValues = function(tree_container) {
    var category_tree, category_tree_inputs;
    category_tree = tree_container.find('.category_tree');
    category_tree_inputs = tree_container.find('.category_tree_inputs');
    category_tree_inputs.html('');
    category_tree.jstree('get_checked', null, true).each(function() {
      $('<input name="' + tree_container.find('.category_ids').attr('name') + '">')
        .attr('type', 'hidden')
        .val(this.id)
        .appendTo(category_tree_inputs);
    });
  };

  CategoriesController.prototype.autocomplete = function() {
    if (this.container.find('input[data-category-autocomplete]').length > 0) {
      return $.each(this.container.find('input[data-category-autocomplete]'), function(
        index,
        select
      ) {
        $(select).select2({
          placeholder: 'Enter a category',
          multiple: true,
          initSelection: function(element, callback) {
            var url;
            url = '/dashboard/api/categories/' + $(select).attr('data-category-id');
            return $.getJSON(
              url,
              { init_selection: 'true', ids: $(select).attr('data-selected-categories') },
              function(data) {
                return callback(data);
              }
            );
          },
          ajax: {
            url: '/dashboard/api/categories/' + $(select).attr('data-category-id'),
            datatype: 'json',
            data: function(term, page) {
              return { per_page: 50, page: page, q: { name_cont: term } };
            },
            results: function(data) {
              return { results: data };
            }
          },
          formatResult: function(category) {
            return category.pretty_name;
          },
          formatSelection: function(category) {
            return category.pretty_name;
          }
        });

        /*
         * select2 will not call initSelection if the input has an empty value
         * (which is always the case with :array_input the way we built it)
         * This is a workaround to trigger the initial value readout
         */
        return $(select).select2('val', []);
      });
    }
  };

  return CategoriesController;
}();

module.exports = CategoriesController;
