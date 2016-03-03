'use strict';

var DNM = require('./app');

require('../vendor/bootstrap');

DNM.registerInitializer(function(){
    var els = $('.blog-posts');
    if (els.length === 0) {
        return;
    }

    var BlogPostsController = require('./blog/blog_posts_controller');
    return new BlogPostsController();
});

DNM.run();
