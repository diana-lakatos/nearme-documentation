var ReviewsController;

ReviewsController = function() {
  function ReviewsController(container, review_options) {
    var i, len, ref, reviewable_parent;
    this.container = container;
    this.review_options = review_options != null ? review_options : {};
    this.path = this.review_options.path;
    this.tab_header = this.container.find('ul[data-tab-header]');
    this.tab_content = this.container.find('div[data-tab-content]');
    ref = this.review_options.reviewables;
    for (i = 0, len = ref.length; i < len; i++) {
      reviewable_parent = ref[i];
      $
        .get(this.path, {
          reviewable_parent_type: reviewable_parent.type,
          reviewable_parent_id: reviewable_parent.id,
          subject: reviewable_parent.subject
        })
        .success(
          function(_this) {
            return function(response) {
              var tab_content;
              if (response.tab_header !== '') {
                if (_this.tab_header) {
                  _this.tab_header.append(response.tab_header);
                }
                _this.container.addClass('reviews-visible');
                tab_content = $(response.tab_content);
                _this.listenForPagination(tab_content);
                return _this.tab_content.append(tab_content);
              }
            };
          }(this)
        );
    }
  }

  ReviewsController.prototype.listenForPagination = function(tab_content) {
    return tab_content.find('.pagination a').on(
      'click',
      function(_this) {
        return function(e) {
          var href;
          e.preventDefault();
          href = $(e.target).closest('a').attr('href');
          if (href) {
            tab_content.html('Loading...');
            return $.get(href, function(response) {
              var new_tab_content;
              new_tab_content = $(response.tab_content);
              tab_content.html(new_tab_content);
              return _this.listenForPagination(tab_content);
            });
          }
        };
      }(this)
    );
  };

  return ReviewsController;
}();

module.exports = ReviewsController;
