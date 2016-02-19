'use strict';

var DNM = require('./app');

require('./intel/vendor/css_browser_selector.min');
require('./intel/vendor/placeholders.min');
require('./intel/vendor/foreach.polyfill');
require('./intel/vendor/hrefid.jquery');
require('./intel/vendor/selectize.mod');
require('./intel/vendor/trueresize');
require('./intel/vendor/geocomplete');
require('./intel/vendor/bootstrap-tab');
require('./intel/vendor/jquery-ui');
require('jQueryRotate/index');
require('cocoon');

DNM.registerInitializer(function(){
    var
        Utils = require('./intel/utils'),
        UI = require('./intel/ui'),
        Onboarding = require('./intel/onboarding'),
        Forms = require('./intel/forms'),
        Fixes = require('./intel/fixes'),
        SeeMore = require('./intel/see_more');

    Utils.initialize();
    UI.initialize();
    Onboarding.initialize();
    Forms.initialize();
    Fixes.initialize();
    SeeMore.initialize();
});

DNM.registerInitializer(function(){
    var els = $('.tutorial-a');
    if (els.length === 0) {
        return;
    }

    require.ensure(['./intel/tutorial'], function(require){
        var Tutorial = require('./intel/tutorial');
        els.each(function(){
            return new Tutorial(this);
        });
    });
});

DNM.registerInitializer(function(){
    var els = $('div[data-fileupload-wrapper]');
    if (els.length === 0) {
        return;
    }

    require.ensure(['./intel/fileupload'], function(require){
        var Fileupload = require('./intel/fileupload');
        return new Fileupload(els);
    });
});

DNM.registerInitializer(function(){
    var els = $('.project-links-listing');
    if (els.length === 0) {
        return;
    }

    require.ensure(['./intel/project_links'], function(require){
        var ProjectLinks = require('./intel/project_links');
        return new ProjectLinks(els);
    });
});

DNM.registerInitializer(function(){
    var els = $('[data-flash-message]');
    if (els.length === 0) {
        return;
    }

    require.ensure(['./intel/flash_message'], function(require){
        var FlashMessage = require('./intel/flash_message');
        els.each(function(){
            return new FlashMessage(this);
        });
    });
});

DNM.registerInitializer(function(){
    var els = $('.project-form-controller');
    if (els.length === 0) {
        return;
    }

    require.ensure(['./intel/sections/project_form'], function(require){
        var ProjectForm = require('./intel/sections/project_form');
        return new ProjectForm(els);
    });
});

DNM.registerInitializer(function(){
    var els = $('#search_filter');
    if (els.length === 0) {
        return;
    }

    require.ensure(['./intel/search/search'], function(require){
        var Search = require('./intel/search/search');
        return new Search(els);
    });
});

DNM.registerInitializer(function(){
    /* initializeModal */
    require.ensure('./intel/modal', function(require){
        var Modal = require('./intel/modal');
        Modal.listen();
    });
});

DNM.registerInitializer(function(){
    $(document).on('init.photomanipulator', function(event, container, options){
        options = options || {};
        require.ensure('./intel/photo/manipulator', function(require){
            var PhotoManipulator = require('./intel/photo/manipulator');
            return new PhotoManipulator($(container), options);
        });
    });
});

DNM.registerInitializer(function(){
    var els = $('div.ckeditor');
    if (els.length === 0) {
        return;
    }

    require.ensure('./ckeditor/init', function(require){
        var CKEDITOR = require('./ckeditor/init');
    });
});

DNM.run();
