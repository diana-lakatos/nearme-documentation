'use strict';

var DNM = require('./app');

require('jquery-ui/ui/widget');
require('jquery-timeago');
require('../vendor/jquery-ui-1.10.4.custom.min');
require('jqueryui-touch-punch');

require('../vendor/bootstrap');
require('../vendor/bootstrap-modal-fullscreen');
require('../vendor/detect-mobile-browser');
require('../vendor/nested_form');
require('cocoon');

$.ajaxSetup({
    'beforeSend': function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
    }
});

function isiOS() {
    return navigator.userAgent.match(/(iPod|iPhone|iPad)/);
}

DNM.registerInitializer(function(){
    var input = $('input[type=hidden].icui');

    if (input.length === 0) {
        return;
    }
    require.ensure('../vendor/icui', function(require){
        require('../vendor/icui');
        return input.icui();
    });
});

DNM.registerCallback('beforeInit', function(){
    $.ajaxSetup({
        'beforeSend': function(xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        }
    });
});

DNM.registerInitializer(function(){
    $(document).on('init.bootstrapswitch', function(){
        require.ensure('./components/forms/bootstrap_switch_initializer', function(require){
            var BootstrapSwitchInitializer = require('./components/forms/bootstrap_switch_initializer');
            return new BootstrapSwitchInitializer('.switch input:visible');
        });
    });

    var els = $('.switch input:visible');
    if (els.length === 0) {
        return;
    }
    require.ensure('./components/forms/bootstrap_switch_initializer', function(require){
        var BootstrapSwitchInitializer = require('./components/forms/bootstrap_switch_initializer');
        return new BootstrapSwitchInitializer(els);
    });
});


DNM.registerInitializer(function(){

    $(document).on('init.selectpicker', function(){
        require.ensure('./components/forms/bootstrap_select_initializer', function(require){
            var BootstrapSelectInitializer = require('./components/forms/bootstrap_select_initializer');
            return new BootstrapSelectInitializer($('.selectpicker'), { iconShow: false });
        });
    });

    $(document).on('nested:fieldAdded', function(event){
        require.ensure('./components/forms/bootstrap_select_initializer', function(require){
            var BootstrapSelectInitializer = require('./components/forms/bootstrap_select_initializer');
            return new BootstrapSelectInitializer(event.field.find('.selectpicker'), { iconShow: false });
        });
    });

    var els = $('.selectpicker');
    if (els.length === 0) {
        return;
    }

    require.ensure('./components/forms/bootstrap_select_initializer', function(require){
        var BootstrapSelectInitializer = require('./components/forms/bootstrap_select_initializer');
        return new BootstrapSelectInitializer(els, { iconShow: false });
    });
});

DNM.registerInitializer(function(){
    var CustomInputs = require('./components/custom_inputs');
    CustomInputs.initialize();

    $(document).on('init.custominputs', function(){
        CustomInputs.initialize();
    });
});

DNM.registerInitializer(function(){
    var Flash = require('./components/flash');
    new Flash();
});

DNM.registerInitializer(function(){
    var els = $('[data-counter-limit]');
    if (els.length === 0) {
        return;
    }

    require.ensure('./components/limiter', function(require){
        var Limiter = require('./components/limiter');
        els.each(function(){
            return new Limiter(this);
        })
    });
});


DNM.registerInitializer(function(){
    var els = $('.multiselect');
    if (els.length === 0) {
        return;
    }

    require.ensure('./components/multiselect', function(require){
        var Multiselect = require('./components/multiselect');
        els.each(function(){
            return new Multiselect.initialize(this);
        })
    });
});

DNM.registerInitializer(function(){
    var els = $('div[data-fileupload-wrapper]');
    if (els.length === 0) {
        return;
    }

    require.ensure('./components/fileupload', function(require){
        var Fileupload = require('./components/fileupload');
        els.each(function(){
            return new Fileupload(this);
        })
    });
});

DNM.registerInitializer(function(){
    $('[rel=tooltip]').tooltip();
});


DNM.registerInitializer(function(){
    var CustomSelects = require('./components/custom_selects');
    CustomSelects.initialize();
});

DNM.registerInitializer(function(){
    if (!isiOS()) {
        return;
    }

    $('input, select, textarea')
    .on('focus', function() {
        $('body').addClass('mobile-fixed-position-fix');
    })
    .on('blur', function() {
        $('body').removeClass('mobile-fixed-position-fix');

        setTimeout(function() {
            $(window).scrollTop($(window).scrollTop() + 1);
        }, 100);
    });
});


DNM.registerInitializer(function(){
    /* setFooterPushHeight */
    var
    wrapper = $('.footer-wrapper'),
    pusher = $('.footer-push');

    if (wrapper.length === 0 || pusher.length === 0) {
        return;
    }

    pusher.height(wrapper.outerHeight());

    $(window).resize(function(){
        pusher.height(wrapper.outerHeight());
    });
});


DNM.registerInitializer(function(){
    /* initializeLinkSubmit */
    $(document).on('click', 'a[rel=submit]', function(e) {
        var form = $(this).closest('form');
        if (form.length > 0) {
            e.preventDefault();
            form.submit();
            return false;
        }
    });
});

DNM.registerInitializer(function(){
    $('abbr.timeago').timeago();
});

DNM.registerInitializer(function(){

    $(document).on('init.supportattachmentform', function(){
        require.ensure(['./sections/support/attachment_form'], function(require){
            var SupportAttachmentForm = require('./sections/support/attachment_form');
            return new SupportAttachmentForm($('#attachment_form'));
        });
    });

    var form = $('#attachment_form');
    if (form.length === 0) {
        return;
    }

    require.ensure(['./sections/support/attachment_form'], function(require){
        var SupportAttachmentForm = require('./sections/support/attachment_form');
        return new SupportAttachmentForm(form);
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

DNM.registerInitializer(function(){

    var Modal = require('./components/modal');
    Modal.listen();

    $(document).on('close.modal', function(){
        Modal.close();
    });

    $(document).on('load.modal', function(event, url){
        Modal.load(url);
    });

    $(document).on('setclass.modal', function(event, klass){
        Modal.setClass(klass);
    });
});

DNM.registerInitializer(function(){
    var els = $('[data-payment-controller]');
    if (els.length === 0) {
        return;
    }
    require.ensure('./sections/buy_sell/payment', function(require){
        var PaymentController = require('./sections/buy_sell/payment');
        return new PaymentController(els);
    });
});

DNM.registerInitializer(function(){
    var els = $('input[data-card-number], input[data-card-code]');
    if (els.length === 0) {
        return;
    }
    require.ensure('jquery.payment', function(require){
        require('jquery.payment');
        $('input[data-card-number]').eq(0).payment('formatCardNumber');
        $('input[data-card-code]').eq(0).payment('formatCardCVC');
    });
});

DNM.registerInitializer(function(){
    var els = document.getElementById('load-sessioncam');
    if (!els) {
        return;
    }

    require.ensure('exports?ServiceTickDetection!./analytics/sessioncam', function(require){
        window.ServiceTickDetection = require('exports?ServiceTickDetection!./analytics/sessioncam');
    });
});

DNM.registerInitializer(function(){
    var els = $('input[type="color"]');
    if (els.length === 0) {
        return;
    }

    require.ensure('spectrum/spectrum', function(require){
        require('spectrum/spectrum');
    });
});

module.exports = DNM;
