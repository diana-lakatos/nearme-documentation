/* global $ */

//= require_relative vendor/css_browser_selector.min.js
//= require_relative vendor/placeholders.min.js
//= require_relative vendor/foreach.polyfill.js
//= require_relative vendor/underscore.js
//= require_relative vendor/hrefid.jquery.js
//= require_relative vendor/selectize.mod.js
//= require_relative vendor/tinynav.js
//= require_relative vendor/trueresize.js
//= require_relative vendor/vequalize.js
//= require_relative vendor/geocomplete.js
//= require_relative vendor/modernizr.js
//= require_relative vendor/bootstrap-tab.js
//= require_relative vendor/jquery-ui.js
//= require_relative vendor/jqueryRotate.js
//= require cocoon
//= require history_jquery
//= require jquery-fileupload/basic
//= require jcrop
//= require_relative sections/search
//= require_tree ./sections

//= require_tree .

$(function(){
    'use strict';

    window.Utils.initialize();
    window.UI.initialize();
    window.Onboarding.initialize();
    window.Tutorial.initialize();
    window.Forms.initialize();
    window.Fixes.initialize();
    window.SeeMore.initialize();
    window.Fileupload.initialize();
    window.ProjectLinks.initialize();
    window.FlashMessage.initialize();
});
