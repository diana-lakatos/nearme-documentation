'use strict';

var DNM = require('./app');

require('../vendor/jquery-ui-1.9.2.custom.min');
require('../vendor/bootstrap');

DNM.registerInitializer(function(){
    var els = $('form[data-blog-posts-form]');
    if (els.length === 0) {
        return;
    }

    require.ensure('./blog/admin/blog_posts_form', function(require){
        var BlogPostsForm = require('./blog/admin/blog_posts_form');
        els.each(function(){
            return new BlogPostsForm(this);
        });
    });
});

DNM.registerInitializer(function(){
    var els = $('div.ckeditor');
    if (els.length === 0) {
        return;
    }

    require.ensure([
        './ckeditor/config'
    ], function(require){
        var CKEDITOR = require('./ckeditor/config');
    });
});

DNM.run();
