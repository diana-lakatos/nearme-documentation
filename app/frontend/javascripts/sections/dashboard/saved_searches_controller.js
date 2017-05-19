var DashboardSavedSearchController,
  urlUtil,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

urlUtil = require('../../lib/utils/url');

DashboardSavedSearchController = function() {
  function DashboardSavedSearchController(container1) {
    this.container = container1;
    this.submitTitle = bind(this.submitTitle, this);
    this.bindTitleSubmits = bind(this.bindTitleSubmits, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.bindEvents();
  }

  DashboardSavedSearchController.prototype.bindEvents = function() {
    this.bindAlertsFrequency();
    this.bindEditLinks();
    return this.bindTitleSubmits();
  };

  DashboardSavedSearchController.prototype.bindAlertsFrequency = function() {
    return $('select[data-alerts-frequency]').on('change', function(event) {
      var input;
      input = $(event.target);
      return $.ajax({
        url: input.closest('form').attr('action'),
        type: 'PATCH',
        data: { alerts_frequency: input.val() }
      });
    });
  };

  DashboardSavedSearchController.prototype.bindEditLinks = function() {
    return $('a[data-saved-search-edit-id]').on('click', function(event) {
      var link, savedSearchId, title, titleCol;
      event.preventDefault();
      savedSearchId = $(this).data('saved-search-edit-id');
      titleCol = $('td[data-saved-search-title=' + savedSearchId + ']');
      link = titleCol.find('a');
      title = link.text();
      link.hide();
      return $('<input/>')
        .attr({ type: 'text', name: 'title', 'data-saved-search-id': savedSearchId })
        .val(title)
        .appendTo(titleCol)
        .focus();
    });
  };

  DashboardSavedSearchController.prototype.bindTitleSubmits = function() {
    return $('table[data-saved-searches]').on(
      'focusout keyup',
      'input[data-saved-search-id]',
      function(_this) {
        return function(event) {
          var self;
          self = $(event.target);
          if (typeof event.keyCode === 'undefined' || event.keyCode === 13) {
            event.preventDefault();
            return _this.submitTitle(self);
          }
        };
      }(this)
    );
  };

  DashboardSavedSearchController.prototype.submitTitle = function(input) {
    var container, link, title;
    container = input.parent();
    link = container.find('a');
    if (!$.trim(input.val()) || input.val() === link.text()) {
      input.remove();
      return link.show();
    } else {
      title = input.val();
      input.remove();
      return $.ajax({
        url: '/dashboard/saved_searches/' + input.data('saved-search-id'),
        type: 'PUT',
        dataType: 'JSON',
        data: { saved_search: { title: title } },
        success: function(_this) {
          return function(data) {
            return _this.showNewTitle(container, data['success'], data['title']);
          };
        }(this),
        error: function(_this) {
          return function() {
            return _this.showNewTitle(container, false);
          };
        }(this)
      });
    }
  };

  DashboardSavedSearchController.prototype.showNewTitle = function(container, success, title) {
    var img, imgErrorUrl, imgSuccessUrl, imgUrl, link;
    if (title == null) {
      title = null;
    }
    link = container.find('a');
    if (success) {
      link.text(title);
    }
    link.show();
    imgSuccessUrl = urlUtil.assetUrl('dashboard/green-check.png');
    imgErrorUrl = urlUtil.assetUrl('dashboard/x-red.png');
    imgUrl = success ? imgSuccessUrl : imgErrorUrl;
    img = $('<img>').attr('src', imgUrl).addClass('status').hide();
    container.append(img);
    return img.fadeIn('slow', function() {
      return img.fadeOut('slow', function() {
        return img.remove();
      });
    });
  };

  return DashboardSavedSearchController;
}();

module.exports = DashboardSavedSearchController;
