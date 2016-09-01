'use strict';

var DNM = require('./app');

require('../vendor/bootstrap');
require('../vendor/bootstrap-modal-fullscreen');

DNM.registerInitializer(function(){
    var els = $('.blog-posts');
    if (els.length === 0) {
        return;
    }

    var BlogPostsController = require('./blog/blog_posts_controller');
    return new BlogPostsController();
});

DNM.registerInitializer(function(){

    var Modal = require('./components/modal');
    Modal.listen();

    $(document).on('close:modal.nearme', function(){
        Modal.close();
    });

    $(document).on('load:modal.nearme', function(event, url){
        Modal.load(url);
    });

    $(document).on('setclass:modal.nearme', function(event, klass){
        Modal.setClass(klass);
    });
});

DNM.registerInitializer(function(){
    /* initializeModalClose */
    /* Re-enable form submit buttons on sign-in/sign-up modal close */
    $(document).on('click.nearme', '.sign-up-modal a.modal-close', function() {
        var reservation_request_form = $('form.reservation_request');
        if(reservation_request_form.length > 0) {
            $.rails.enableFormElements(reservation_request_form);
            reservation_request_form.find('[data-behavior=reviewBooking]').removeClass('click-disabled');
        }
    });
});

DNM.registerInitializer(function(){
    $(document).on('init:modalform.nearme', function(event, context){
        require.ensure('./components/modal_form', function(require){
            var ModalForm = require('./components/modal_form');
            return new ModalForm($(context));
        });
    });
});

DNM.registerInitializer(function(){
    $( document ).on('modal-shown.nearme', function(e, containerElement) {
        $(containerElement).find('input[data-authenticity-token]').val($('meta[name="authenticity_token"]').attr('content'));
    });
});

DNM.run();
