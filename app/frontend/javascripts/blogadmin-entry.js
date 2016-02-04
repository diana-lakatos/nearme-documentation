'use strict';

require('expose?$!expose?jQuery!jquery');
require('jquery-ujs/src/rails');
require('../vendor/jquery-ui-1.9.2.custom.min');
require('../vendor/bootstrap');

(function(){

    var DNM = require('./dnm');

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
            './ckeditor/init'
        ], function(require){
            var CKEDITOR = require('./ckeditor/init');
        });
    });


    DNM.run();

    window.DNM = DNM;
}());
