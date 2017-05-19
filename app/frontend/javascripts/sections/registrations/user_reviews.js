var UserReviews;

UserReviews = function() {
  function UserReviews(container) {
    this.container = container;
    this.loadingContainer = this.container.find('[data-loading]');
    this.contentContainer = $('[data-reviews-content]');
    this.countContainer = $('[data-reviews-count]');
    this.reviewsDropdown = this.container.find('[data-reviews-dropdown]');
    this.bindEvents();
  }

  UserReviews.prototype.bindEvents = function() {
    var paginationInit;
    this.reviewsDropdown.find('li').click(
      function(_this) {
        return function(event) {
          _this.reviewsDropdown.find('[data-title]').text($(event.target).text());
          _this.contentContainer.hide();
          _this.loadingContainer.show();
          return $.ajax({
            url: _this.reviewsDropdown.data('url'),
            method: 'GET',
            data: { option: $(event.target).data('option') },
            success: function(data) {
              _this.countContainer.text(data.count);
              _this.contentContainer.html(data.template);
              _this.contentContainer.show();
              _this.loadingContainer.hide();
              return paginationInit();
            }
          });
        };
      }(this)
    );
    if (this.container.find('[data-sorting-reviews]').length) {
      this.reviewsDropdown.find('li:first').click();
    }
    return paginationInit = function(_this) {
      return function() {
        _this.reviewsPagination = $('[data-reviews-content]').find('.pagination');
        return _this.reviewsPagination.find('li a').click(function(event) {
          _this.contentContainer.hide();
          _this.loadingContainer.show();
          $.ajax({
            url: $(event.target).attr('href') || $(event.target).parent().attr('href'),
            method: 'GET',
            success: function(data) {
              _this.contentContainer.html(data.template);
              _this.loadingContainer.hide();
              _this.contentContainer.show();
              return paginationInit();
            }
          });
          return false;
        });
      };
    }(this);
  };

  return UserReviews;
}();

module.exports = UserReviews;
