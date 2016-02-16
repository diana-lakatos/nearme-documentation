/* global require */
'use strict';

require('jquery-ujs/src/rails');
require('jquery-ui/ui/widget');
require('bootstrap-sass/assets/javascripts/bootstrap');
require('cocoon');
require('jquery-timeago');

(function($){

    var DNM = require('./dnm');

    DNM.registerInitializer(function(){
        var fields = $('[data-address-field]');

        if (fields.length > 0) {
            require.ensure('./new_ui/address_field/address_controller', function(require){
                var AddressController = require('./new_ui/address_field/address_controller');
                return new AddressController();
            });
        }

        $('html').on('loaded.dialog', function(){
            require.ensure('./new_ui/address_field/address_controller', function(require){
                var AddressController = require('./new_ui/address_field/address_controller');
                return new AddressController('.dialog');
            });
        });
    });

    DNM.registerInitializer(function(){
        var inputs = $('input[data-attachment-input]');
        if (inputs.length === 0) {
            return;
        }

        require.ensure('./new_ui/modules/attachment_input', function(require){
            var AttachmentInput = require('./new_ui/modules/attachment_input');
            inputs.each(function(){
                return new AttachmentInput(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('[data-category-autocomplete]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/modules/category_autocomplete_input', function(require){
            var CategoryAutocompleteInput = require('./new_ui/modules/category_autocomplete_input');
            els.each(function(){
                return new CategoryAutocompleteInput(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('[data-category-tree-input]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/modules/category_tree_input', function(require){
            var CategoryTreeInput = require('./new_ui/modules/category_tree_input');
            els.each(function(){
                return new CategoryTreeInput(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var Dialog = require('./new_ui/modules/dialog');
        return new Dialog();
    });

    DNM.registerInitializer(function(){
        var ExternalLinks = require('./new_ui/modules/external_links');
        return new ExternalLinks();
    });

    DNM.registerInitializer(function(){
        var FlashMessage = require('./new_ui/modules/flash_message');
        return new FlashMessage();
    });

    DNM.registerInitializer(function(){
        var Forms = require('./new_ui/forms/forms');
        return new Forms();
    });

    DNM.registerInitializer(function(){
        var els = $('[data-image-input]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/modules/image_input', function(require){
            var ImageInput = require('./new_ui/modules/image_input');
            els.each(function(){
                return new ImageInput(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var Navigation = require('./new_ui/modules/navigation');
        return new Navigation();
    });

    DNM.registerInitializer(function(){

        var els = $('nav.panel-nav[data-internal-nav]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/modules/panel_tabs', function(require){
            var PanelTabs = require('./new_ui/modules/panel_tabs');
            els.each(function(){
                return new PanelTabs(this);
            });
        });
    });

    DNM.registerInitializer(function(){

        var els = $('[data-phone-fields-container]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/modules/phone_numbers', function(require){
            var PhoneNumbers = require('./new_ui/modules/phone_numbers');
            return new PhoneNumbers();
        });
    });

    DNM.registerInitializer(function(){
        var els = $('[data-popup]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/modules/popup', function(require){
            var Popup = require('./new_ui/modules/popup');
            els.each(function(){
                return new Popup(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('.selectize-tags');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/modules/tags', function(require){
            var Tags = require('./new_ui/modules/tags');
            els.each(function(){
                return new Tags(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('table[data-saved-searches]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/controllers/saved_searches_controller', function(require){
            var SavedSearchesController = require('./new_ui/controllers/saved_searches_controller');
            els.each(function(){
                return new SavedSearchesController(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('#reviews');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/reviews/reviews', function(require){
            var Reviews = require('./new_ui/reviews/reviews');
            els.each(function(){
                return new Reviews(this);
            });
        });
    });

    DNM.registerInitializer(function(){

        var els = $('form[data-payouts-form]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/controllers/stripe_connect_controller', function(require){
            var StripeConnectController = require('./new_ui/controllers/stripe_connect_controller');
            els.each(function(){
                return new StripeConnectController(this);
            });
        });
    });

    DNM.registerInitializer(function(){

        var els = $('#white-label-form');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/controllers/white_label_controller', function(require){
            var WhiteLabelController = require('./new_ui/controllers/white_label_controller');
            els.each(function(){
                return new WhiteLabelController(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        /* This is to fix the wrong state of white-label-fields (shown or not shown) due to white_label_enabled checkbox keeping the same state on page refresh even though it's not persisted in the DB */
        var
            el = $('#company_white_label_enabled'),
            fields = $('#white-label-fields');

        if (el.length === 0 || fields.length === 0) {
            return;
        }

        if(el.is(':checked')) {
            fields.attr('class', 'collapse in');
        }
        else {
            fields.attr('class', 'collapse');
        }
    });

    DNM.registerInitializer(function(){

        var els = $('[data-messages-form]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/controllers/messages_controller', function(require){
            var MessagesController = require('./new_ui/controllers/messages_controller');
            els.each(function(){
                return new MessagesController(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('[data-document-requirements]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/controllers/document_requirements_controller', function(require){
            var DocumentRequirementsController = require('./new_ui/controllers/document_requirements_controller');
            els.each(function(){
                return new DocumentRequirementsController(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('.rfq-form-a');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/controllers/ticket_message_controller', function(require){
            var TicketMessageController = require('./new_ui/controllers/ticket_message_controller');
            els.each(function(){
                return new TicketMessageController(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('.products-shippo');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/controllers/shippo_controller', function(require){
            var ShippoController = require('./new_ui/controllers/shippo_controller');
            els.each(function(){
                return new ShippoController(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('.rental-shipping-type-section');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/controllers/rental_shipping_controller', function(require){
            var ShippoController = require('./new_ui/controllers/rental_shipping_controller');
            els.each(function(){
                return new ShippoController(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('.fixed-price-container');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/listings/fixed_price', function(require){
            var FixedPrice = require('./new_ui/listings/fixed_price');
            els.each(function(){
                return new FixedPrice(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('[data-booking-type-list]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/listings/booking_type', function(require){
            var BookingType = require('./new_ui/listings/booking_type');
            els.each(function(){
                return new BookingType(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('[data-listing-enabled]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/listings/sync_enabled_fields', function(require){
            var SyncEnabledFields = require('./new_ui/listings/sync_enabled_fields');
            return new SyncEnabledFields(els);
        });
    });

    DNM.registerInitializer(function(){
        var els = $('.prices-container');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/listings/price_fields', function(require){
            var PriceFields = require('./new_ui/listings/price_fields');
            els.each(function(){
                return new PriceFields(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('[data-location-field]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/listings/location_field', function(require){
            var PriceFields = require('./new_ui/listings/location_field');
            els.each(function(){
                return new PriceFields(this);
            });
        });
    });


    DNM.registerInitializer(function(){
        var els = $('.transactable-schedule-container');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/listings/schedule', function(require){
            var Schedule = require('./new_ui/listings/schedule');
            els.each(function(){
                return new Schedule(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('.listing-availability');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/listings/availability_rules', function(require){
            var AvailabilityRules = require('./new_ui/listings/availability_rules');
            els.each(function(){
                return new AvailabilityRules(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        var els = $('.services_list');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/controllers/edit_user_controller', function(require){
            var EditUserController = require('./new_ui/controllers/edit_user_controller');
            els.each(function(){
                return new EditUserController(this);
            });
        });
    });

    DNM.registerInitializer(function(){

        $(document).on('init.limiter', function(event, elements){
            require.ensure('./new_ui/modules/limited_input', function(require){
                var Limiter = require('./new_ui/modules/limited_input');
                $(elements).each(function(){
                    return new Limiter(this);
                });
            });
        });


        var els = $('[data-counter-limit]');
        if (els.length === 0) {
            return;
        }
        require.ensure('./new_ui/modules/limited_input', function(require){
            var Limiter = require('./new_ui/modules/limited_input');
            els.each(function(){
                return new Limiter(this);
            });
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('linechart.dnm', function(event, el, values, labels){
            require.ensure('./new_ui/charts/chart_wrappers/line', function(require){
                var LineChart = require('./new_ui/charts/chart_wrappers/line');
                new LineChart(el, values, labels);
            });
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('dimensiontemplates.dnm', function(event, el, units){
            require.ensure('./new_ui/modules/dimension_templates', function(require){
                var DimensionTemplates = require('./new_ui/modules/dimension_templates');
                new DimensionTemplates(el, units);
            });
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('photomanipulator.dnm', function(event, el){
            require.ensure('./new_ui/modules/photo_manipulator', function(require){
                var PhotoManipulator = require('./new_ui/modules/photo_manipulator');
                new PhotoManipulator(el);
            });
        });
    });

    DNM.registerInitializer(function(){
        $('abbr.timeago').timeago();
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
        $(document).on('init.shippingprofilescontroller', function(){
            require.ensure('./new_ui/controllers/shipping_profiles_controller', function(require){
                var ShippingProfilesController = require('./new_ui/controllers/shipping_profiles_controller');
                return new ShippingProfilesController('form.profiles_shipping_category_form');
            });
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


    $(function(){
        DNM.run();
    });

    window.DNM = DNM;

}(jQuery));
