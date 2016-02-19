'use strict';

var DNM = require('./app');

require('../vendor/bootstrap');

DNM.registerInitializer(function(){
    var els = $('.blog-posts');
    if (els.length === 0) {
        return;
    }

    require.ensure('./blog/blog_posts_controller', function(require){
        var BlogPostsController = require('./blog/blog_posts_controller');
        els.each(function(){
            return new BlogPostsController($(this));
        });
    });
});

DNM.run();
