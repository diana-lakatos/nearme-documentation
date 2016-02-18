/* global require, $ */
'use strict';
require('../vendor/bootstrap-sass-2.3.2.2/vendor/assets/javascripts/bootstrap')
require('../vendor/detect-mobile-browser');
require('../vendor/nested_form');

require('cocoon');

/*  This should be rewritten at some point */

(function(){


    var DNM = require('./dnm-common');

    DNM.registerInitializer(function(){
        var els = $('#edit_company');
        if (els.length === 0) {
            return;
        }

        require.ensure('./sections/company_form', function(require){
            var CompanyForm = require('./sections/company_form');
            return new CompanyForm(els);
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('init.dashboardcontroller', function(){
            require.ensure('./sections/dashboard/dashboard_controller', function(require){
                var DashboardController = require('./sections/dashboard/dashboard_controller');
                return new DashboardController($('section.dashboard'));
            });
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('init.photomanipulator', function(event, container, options){
            options = options || {};
            require.ensure('./components/photo/manipulator', function(require){
                var PhotoManipulator = require('./components/photo/manipulator');
                return new PhotoManipulator($(container), options);
            });
        });
    });


    DNM.registerInitializer(function(){
        var els = $('#reviews');
        if (els.length === 0) {
            return;
        }

        require.ensure(['./sections/dashboard/reviews_controller'], function(require){
            var DashboardReviewsController = require('./sections/dashboard/reviews_controller');
            return new DashboardReviewsController(els);
        });
    });

    DNM.registerInitializer(function(){
        var table = $('table[data-saved-searches]');
        if (table.length === 0) {
            return;
        }

        require.ensure(['./sections/dashboard/saved_searches_controller'], function(require){
            var DashboardSavedSearchesController = require('./sections/dashboard/saved_searches_controller');
            return new DashboardSavedSearchesController(table);
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('init.sellerattachmentaccesslevelselector', function(event, el){
            el = el || document;
            require.ensure('./components/seller_attachment_access_level_selector', function(require){
                var SellerAttachmentAccessLevelSelector = require('./components/seller_attachment_access_level_selector');
                return new SellerAttachmentAccessLevelSelector(el);
            });
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('init.shippingprofiles', function(event, profile_add_success){
            require.ensure('./sections/dashboard/shipping_profiles', function(require){
                var ShippingProfiles = require('./sections/dashboard/shipping_profiles');
                return new ShippingProfiles('.profiles_shipping_category_form', profile_add_success);
            });
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('init.reservationlistcontroller', function(event, container, reservation_id){
            require.ensure('./sections/reservations/list_controller', function(require){
                var ReservationsListController = require('./sections/reservations/list_controller');
                return new ReservationsListController(container, reservation_id);
            });
        });
    });

    DNM.registerInitializer(function(){
        var el = $('.message-form');
        if (el.length === 0) {
            return;
        }

        require.ensure('./sections/support/ticket_message_controller', function(require){
            var SupportTicketMessageController = require('./sections/support/ticket_message_controller');
            return new SupportTicketMessageController(el);
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('linechart.dnm', function(event, el, values, labels){
            require.ensure('./components/chart/line', function(require){
                var LineChart = require('./components/chart/line');
                new LineChart(el, values, labels);
            });
        });
    });

    DNM.registerInitializer(function(){
        var el = $('#dashboard-analytics-controller');
        if (el.length === 0) {
            return;
        }

        require.ensure('./sections/dashboard/analytics_controller', function(require){
            var DashboardAnalyticsController = require('./sections/dashboard/analytics_controller');
            return new DashboardAnalyticsController(el);
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('init.userdimensionstemplates', function(event, units){
            require.ensure('./sections/dashboard/user_dimensions_templates', function(require){
                var UserDimensionsTemplates = require('./sections/dashboard/user_dimensions_templates');
                new UserDimensionsTemplates(units);
            });
        });
    });

    DNM.registerInitializer(function(){

        $(document).on('init.locationform', function(){
            var form = $('#location-form');
            if (form.length === 0) {
                return;
            }

            require.ensure([
                './sections/dashboard/location_controller',
                './components/limiter'
                ], function(require){
                var
                    DashboardLocationController = require('./sections/dashboard/location_controller'),
                    Limiter = require('./components/limiter');

                new DashboardLocationController(form);
                new Limiter(form.find('[data-counter-limit]'));
            });
        });
    });

    DNM.registerInitializer(function(){
        var form = $('#listing-form');
        if (form.length === 0) {
            return;
        }

        require.ensure([
            './sections/dashboard/listing_controller',
            './sections/categories'
            ], function(require){
            var
                DashboardListingController = require('./sections/dashboard/listing_controller'),
                CategoriesController = require('./sections/categories');

            new DashboardListingController(form);
            new CategoriesController(form);
        });
    });

    DNM.registerInitializer(function(){
        $(document).on('init.stripeconnectcontroller', function(){
            require.ensure('./sections/dashboard/stripe_connect_controller', function(require){
                var DashboardStripeConnectController = require('./sections/dashboard/stripe_connect_controller');
                new DashboardStripeConnectController($('form[data-payouts-form]'));
            });
        });
    });

    DNM.registerInitializer(function(){
        var form = $('[data-payouts-form="1"]');
        if (form.length === 0) {
            return;
        }

        require.ensure('./sections/dashboard/address_controller', function(require){
            var DashboardAddressController = require('./sections/dashboard/address_controller');
            return new DashboardAddressController(form);
        });
    });

    DNM.registerInitializer(function(){
        var form = $('#product_form, #boarding_form');
        if (form.length === 0) {
            return;
        }

        require.ensure([
            './sections/dashboard/address_controller',
            './sections/buy_sell/boarding_form',
            './sections/buy_sell/shippo_fields_manager',
            './sections/categories'], function(require){
            var
                AddressController = require('./sections/dashboard/address_controller'),
                BoardingForm = require('./sections/buy_sell/boarding_form'),
                ShippoFieldsManager = require('./sections/buy_sell/shippo_fields_manager'),
                CategoriesController = require('./sections/categories');

            new AddressController(form);
            new BoardingForm(form);
            new CategoriesController(form);
            new ShippoFieldsManager(form.data('dimensions-template'));
        });
    });

    DNM.registerInitializer(function(){
        var el = $('input[data-tags]');
        if (el.length === 0) {
            return;
        }

        require.ensure('./components/tags', function(require){
            var Tags = require('./components/tags');
            return new Tags();
        });
    });

    DNM.registerInitializer(function(){
        var el = $('#user_blog_post_published_at');
        if (el.length === 0) {
            return;
        }

        require.ensure('./sections/dashboard/user_blog_post_form', function(require){
            var UserBlogPostForm = require('./sections/dashboard/user_blog_post_form');
            return new UserBlogPostForm();
        });
    });

    DNM.run();

    window.DNM = DNM;
}());
