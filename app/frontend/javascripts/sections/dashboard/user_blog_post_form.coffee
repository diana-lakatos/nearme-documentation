require('../../../vendor/jquery-ui-1.10.4.custom.min')

module.exports = class UserBlogPostForm
  constructor: ->
    @initialize()

  initialize: ->
    $('#user_blog_post_published_at').datepicker({ showOtherMonths: true, selectOtherMonths: false, dateFormat: 'yy-mm-dd'})
