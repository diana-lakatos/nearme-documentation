'use strict';

var DNM = require('./app');

require('../vendor/jquery-ui-1.9.2.custom.min');
require('jquery-ui/ui/widget');
require('bootstrap-sass/assets/javascripts/bootstrap');
require('bootstrap-switch/src/coffee/bootstrap-switch');
require('../vendor/nested_form');
require('../vendor/cocoon');
require('timeago');

DNM.registerInitializer(function(){
  var els = $('div[data-fileupload-wrapper]');
  if (els.length === 0) {
    return;
  }

  require.ensure('./components/fileupload', function(require){
    var Fileupload = require('./components/fileupload');
    els.each(function(){
      return new Fileupload(this);
    });
  });
});

DNM.registerInitializer(function(){
  $('[rel=tooltip]').tooltip();
});

DNM.registerInitializer(function(){
  var Forms = require('./instance_admin/forms/forms');
  return new Forms();
});

DNM.registerInitializer(function(){
  $('input.bootstrap_switch').bootstrapSwitch();
});

DNM.registerInitializer(function(){
  // Graceful degradation for missing inline_labels
  // Make the original label visible
  $('.control-group.boolean .controls label.checkbox').each(function() {
    try {
      var text = $(this).html();
      if(text.match(/^\s*<[^<>]+>\s*$/)) {
        $(this).parents('.control-group.boolean').find('label.boolean.control-label').show();
      }
    } catch(e) {
      // Avoid graceful degradation code from impacting page
      // errors, if present are not treated
    }
  });
});

DNM.registerInitializer(function(){
  var previous_value = $('#instance_wish_lists_icon_set').val();

  $('#instance_wish_lists_icon_set').on('change', function(){
    var icon_set = $('#instance_wish_lists_icon_set').val();

    $('#set-' + previous_value).hide(0, function(){
      $('#set-' + icon_set).show(0);
      previous_value = icon_set;
    });

    return;
  });
});

DNM.registerInitializer(function(){
  var els = $('textarea[data-editor]');
  if (els.length === 0) {
    return;
  }

  require.ensure('./components/ace_editor_textarea_binding', function(require){
    var bindEditor = require('./components/ace_editor_textarea_binding');
    els.each(function(){
      bindEditor(this);
    });
  });
});

DNM.registerInitializer(function(){
  var HelpBar = require('./instance_admin/help_bar');
  return new HelpBar();
});

DNM.registerInitializer(function(){
  $('.line-item-btn').popover();

  var input = $('input[type=hidden].icui');

  if (input.length === 0) {
    return;
  }
  require.ensure('../vendor/icui', function(){
    return input.icui();
  });
});

/* Reveal input when user clicks 'add new' */
DNM.registerInitializer(function(){
  var hidden = $('.add-new-hidden').hide();

  $('.add-new-btn').on('click', function() {
    hidden.slideDown();
  });
});

DNM.registerInitializer(function(){
  /* Display file name on upload */
  $('.upload-file').change(function() {
    $('#' + $(this).attr('name')).append($(this).val().split('\\').pop());
  });
});

DNM.registerInitializer(function(){
  //Prefences Checkbox slide
  var cancellationSettings = $('.cancellation-settings').hide();
  var passwordSettings = $('.password-settings').hide();


  $('#cancellation-check').on('change', function() {
    if($(this).is(':checked')) {
      return cancellationSettings.slideDown();
    }
    cancellationSettings.slideUp();
  });

  $('#password-check').on('change', function() {
    if($(this).is(':checked')) {
      return passwordSettings.slideDown();
    }
    passwordSettings.slideUp();
  });
});

DNM.registerInitializer(function(){
  $('[data-submit-form]').on('click', function() {
    $($(this).data('form-selector')).each(function(){
      $(this).submit();
    });
  });
});

DNM.registerInitializer(function(){
  $('.translation-default-button').on('click', function() {
    $(this).closest('.translations-input-container').find('.default-text').toggle();
  });
});

DNM.registerInitializer(function(){
  $(document).on('line:chart.nearme', function(event, el, values, labels){
    require.ensure('./components/chart/line', function(require){
      var LineChart = require('./components/chart/line');
      new LineChart(el, values, labels);
    });
  });
});

DNM.registerInitializer(function(){
  var main = $('#main-container');

  if (main.hasClass('listings')) {
    require.ensure('./instance_admin/sections/listings', function(require){
      var InstanceAdminListingsController = require('./instance_admin/sections/listings');
      new InstanceAdminListingsController(main);
    });
  }

  if (main.hasClass('products')) {
    require.ensure('./instance_admin/sections/products', function(require){
      var InstanceAdminProductsController = require('./instance_admin/sections/products');
      new InstanceAdminProductsController(main);
    });
  }

  if (main.hasClass('documents_upload')) {
    require.ensure('./instance_admin/sections/documents_upload', function(require){
      var InstanceAdminDocumentsUploadController = require('./instance_admin/sections/documents_upload');
      new InstanceAdminDocumentsUploadController(main);
    });
  }

  if (main.hasClass('seller_attachments')) {
    require.ensure('./instance_admin/sections/seller_attachments', function(require){
      var InstanceAdminSellerAttachmentsController = require('./instance_admin/sections/seller_attachments');
      new InstanceAdminSellerAttachmentsController(main);
    });
  }

  if (main.find('.content-container.reports').length > 0) {
    require.ensure('./instance_admin/sections/listings', function(require){
      var InstanceAdminListingsController = require('./instance_admin/sections/listings');
      new InstanceAdminListingsController(main);
    });
  }

  if (main.hasClass('users') || main.hasClass('projects') || main.hasClass('groups')) {
    require.ensure('./instance_admin/sections/users', function(require){
      var InstanceAdminUsersController = require('./instance_admin/sections/users');
      new InstanceAdminUsersController(main);
    });
  }

  if (main.hasClass('reviews')) {
    require.ensure('./instance_admin/sections/reviews', function(require){
      var InstanceAdminReviewsController = require('./instance_admin/sections/reviews');
      new InstanceAdminReviewsController(main);
    });
  }

  if (main.hasClass('rating_systems')) {
    require.ensure('./instance_admin/sections/rating_systems', function(require){
      var InstanceAdminRatingSystemsController = require('./instance_admin/sections/rating_systems');
      new InstanceAdminRatingSystemsController(main);
    });
  }

  if (main.hasClass('spam_reports')) {
    require.ensure('./instance_admin/sections/spam_reports', function(require){
      var InstanceAdminSpamReportsController = require('./instance_admin/sections/spam_reports');
      new InstanceAdminSpamReportsController(main);
    });
  }

  if (main.hasClass('projects') || main.hasClass('advanced_projects')) {
      require.ensure('./instance_admin/sections/projects', function(require){
          var InstanceAdminProjectsController = require('./instance_admin/sections/projects');
          new InstanceAdminProjectsController(main);
      });
  }

  if (main.hasClass('custom_attributes')) {
      require.ensure('./instance_admin/sections/custom_attributes', function(require){
          var InstanceAdminCustomAttributesController = require('./instance_admin/sections/custom_attributes');
          new InstanceAdminCustomAttributesController(main);
      });
  }
});

DNM.registerInitializer(function(){
  var modal = $('.settings-controller-modal #instanceAdminModal');

  if (modal.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/settings', function(require){
    var InstanceAdminSettingsController = require('./instance_admin/sections/settings');
    return new InstanceAdminSettingsController(modal);
  });
});

DNM.registerInitializer(function(){
  var editLocationForm = $('#edit-location-types-form');
  if (editLocationForm.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/locations', function(require){
    var InstanceAdminLocationsController = require('./instance_admin/sections/locations');
    return new InstanceAdminLocationsController(editLocationForm);
  });
});

DNM.registerInitializer(function(){
  $('.payment-gateway-select').on('change', function(){
    $('.instance-payment-gateway-form').html('Loading...');
    $(this).submit();
  });
});

DNM.registerInitializer(function(){
  var el = $('#payment-gateways .country-select');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/payment_gateway_select', function(require){
    var InstanceAdminPaymentGatewaySelect = require('./instance_admin/sections/payment_gateway_select');
    return new InstanceAdminPaymentGatewaySelect(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('#theme_form');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/theme', function(require){
    var ThemeController = require('./instance_admin/sections/theme');
    return new ThemeController(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('table#pages');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/pages', function(require){
    var PagesController = require('./instance_admin/sections/pages');
    return new PagesController(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('#instance_admins_form');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/admins/admins_controller', function(require){
    var AdminsController = require('./instance_admin/sections/admins/admins_controller');
    return new AdminsController(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('#instance_admin_roles');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/admins/admin_roles_controller', function(require){
    var AdminRolesController = require('./instance_admin/sections/admins/admin_roles_controller');
    return new AdminRolesController(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('form[data-partner-form]');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/partners', function(require){
    var PartnersController = require('./instance_admin/sections/partners');
    return new PartnersController(el);
  });
});

DNM.registerInitializer(function(){
  $('abbr.timeago').timeago();
});

DNM.registerInitializer(function(){
  var el = $('#user_assigned_to_id');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/support_assigner', function(require){
    var SupportAssigner = require('./instance_admin/sections/support_assigner');
    return new SupportAssigner(el);
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
  var el = $('table#faqs');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/support/faqs', function(require){
    var FaqsController = require('./instance_admin/sections/support/faqs');
    return new FaqsController(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('.approval_requests');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/approval_requests', function(require){
    var InstanceAdminApprovalRequestsController = require('./instance_admin/sections/approval_requests');
    return new InstanceAdminApprovalRequestsController(el);
  });

});

DNM.registerInitializer(function(){
  var el = $('#workflow_form');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/workflow_form_controller', function(require){
    var InstanceAdminWorkflowFormController = require('./instance_admin/sections/workflow_form_controller');
    return new InstanceAdminWorkflowFormController(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('ol.formComponentPanelList');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/form_components', function(require){
    var FormComponents = require('./instance_admin/sections/form_components');
    return new FormComponents(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('.transactable-schedule-container');
  if (el.length === 0) {
    return;
  }

  require.ensure('./new_ui/listings/schedule', function(require){
    var ListingsSchedule = require('./new_ui/listings/schedule');
    return new ListingsSchedule(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('#category_form');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/categories', function(require){
    var InstanceAdminCategoriesController = require('./instance_admin/sections/categories');
    return new InstanceAdminCategoriesController(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('#search-sortable');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/search', function(require){
    var InstanceAdminSearchSettings = require('./instance_admin/sections/search');
    return new InstanceAdminSearchSettings();
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
  var el = $('#form-components-manager');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/form_components_manager', function(require){
    var InstanceAdminFormComponentsManager = require('./instance_admin/sections/form_components_manager');
    return new InstanceAdminFormComponentsManager(el);
  });
});


DNM.registerInitializer(function(){
  var el = $('form[data-dimensions-template-form]');
  if (el.length === 0) {
    return;
  }

  require.ensure('./instance_admin/sections/shipping_options/dimensions_templates', function(require){
    var DimensionsTemplates = require('./instance_admin/sections/shipping_options/dimensions_templates');
    return new DimensionsTemplates(el);
  });
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
  $(document).on('init:shippingprofiles.nearme', function(event, profile_add_success){
    require.ensure('./sections/dashboard/shipping_profiles', function(require){
      var ShippingProfiles = require('./sections/dashboard/shipping_profiles');
      return new ShippingProfiles('.profiles_shipping_category_form', profile_add_success);
    });
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:photomanipulator.nearme', function(event, container, options){
    options = options || {};
    require.ensure('./components/photo/manipulator', function(require){
      var PhotoManipulator = require('./components/photo/manipulator');
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
    require('./ckeditor/init');
  });
});

DNM.registerInitializer(function(){
  // Make fa-icon submitting icons submit the form
  $('.fa-action-icon-submit').click(function() {
    $(this).closest('form').submit();
  });
});

DNM.registerInitializer(function(){
  var els = $('input[type="color"]');
  if (els.length === 0) {
    return;
  }

  require.ensure('spectrum-colorpicker', function(require){
    require('spectrum-colorpicker');
  });
});

DNM.registerInitializer(function(){

  var els = $('[data-booking-type-list]');
  if (els.length === 0) {
    return;
  }
  require.ensure('./instance_admin/forms/panel_tabs', function(require){
    var PanelTabs = require('./instance_admin/forms/panel_tabs');
    els.each(function(){
      return new PanelTabs(this);
    });
  });
});


DNM.registerInitializer(function(){
  var ChosenInitializer = require('./instance_admin/forms/chosen');
  function run(){
    new ChosenInitializer();
  }
  $(document).on('cocoon:after-insert', run);
  run();
});

DNM.registerInitializer(function(){
  var els = $('[data-photo-uploader-versions]');
  if (els.length === 0) {
    return;
  }

  require.ensure('./instance_admin/forms/photo_upload_versions', function(require){
    var PhotoUploadVersions = require('./instance_admin/forms/photo_upload_versions');
    return new PhotoUploadVersions();
  });
});

DNM.registerInitializer(function(){
  var els = $('[data-default-images]');
  if (els.length === 0) {
    return;
  }

  require.ensure('./instance_admin/forms/default_images', function(require){
    var DefaultImages = require('./instance_admin/forms/default_images');
    return new DefaultImages();
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:paymentgateway.nearme', function(event, container, options){
    options = options || {};
    require.ensure('./instance_admin/sections/payment_gateway_form', function(require){
      var InstanceAdminPaymentGatewayForm = require('./instance_admin/sections/payment_gateway_form');
      return new InstanceAdminPaymentGatewayForm($(container), options);
    });
  });
});

DNM.run();
