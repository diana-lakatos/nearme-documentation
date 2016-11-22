var els = $('.blog-posts');
if (els.length > 0) {
  require.ensure('../../blog/blog_posts_controller', (require)=>{
    var BlogPostsController = require('../../blog/blog_posts_controller');
    return new BlogPostsController();
  });
}
