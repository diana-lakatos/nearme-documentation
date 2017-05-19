var UserBlogPostForm;

require('../../../vendor/jquery-ui-1.10.4.custom.min');

UserBlogPostForm = function() {
  function UserBlogPostForm() {
    this.initialize();
  }

  UserBlogPostForm.prototype.initialize = function() {
    return $(
      '#user_blog_post_published_at'
    ).datepicker({ showOtherMonths: true, selectOtherMonths: false, dateFormat: 'yy-mm-dd' });
  };

  return UserBlogPostForm;
}();

module.exports = UserBlogPostForm;
