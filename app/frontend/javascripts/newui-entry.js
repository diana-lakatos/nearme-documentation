'use strict';

var DNM = require('./app');

require('jquery-ui/ui/widget');
require('bootstrap-sass/assets/javascripts/bootstrap');
require('../vendor/cocoon');
require('timeago');

DNM.registerInitializer(function(){
  var fields = $('[data-address-field]');

  if (fields.length > 0) {
    require.ensure('./new_ui/address_field/address_controller', function(require){
      var AddressController = require('./new_ui/address_field/address_controller');
      return new AddressController();
    });
  }

  $('html').on('loaded:dialog.nearme', function(){
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
  var els = $('[data-complete-reservation]');
  if (els.length === 0) {
    return;
  }
  require.ensure('./new_ui/controllers/complete_reservation_controller', function(require){
    var CompleteReservationController = require('./new_ui/controllers/complete_reservation_controller');
    els.each(function(){
      return new CompleteReservationController(this);
    });
  });
});

DNM.registerInitializer(function(){
  var els = $('[data-order-items]');
  if (els.length === 0) {
    return;
  }
  require.ensure('./new_ui/controllers/complete_reservation_controller', function(require){
    var OrderItemsController = require('./new_ui/controllers/order_items_controller');
    els.each(function(){
      return new OrderItemsController(this);
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
  $(document).on('init:user_messages.nearme', function(){
    require.ensure('./new_ui/controllers/messages_controller', function(require){
      var MessagesController = require('./new_ui/controllers/messages_controller');
      return new MessagesController($('[data-messages-form]'));
    });
  });

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
  var els = $('[data-shipping-methods-list]');
  if (els.length === 0) {
    return;
  }
  require.ensure('./new_ui/controllers/dimensions_template_controller', function(require){
    var DimensionsTemplateController = require('./new_ui/controllers/dimensions_template_controller');
    els.each(function(){
      return new DimensionsTemplateController(this);
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
  var els = $('[data-transactable-collaborator]');
  if (els.length === 0) {
    return;
  }
  require.ensure('./new_ui/listings/collaborators', function(require){
    var Collaborators = require('./new_ui/listings/collaborators');
    return new Collaborators($(els[0]).closest('form'));
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
  var els = $('.document-requirements-container');
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
  $(document).on('init:limiter.nearme', function(event, elements){
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
  $(document).on('line:chart.nearme', function(event, el, values, labels){
    require.ensure('./new_ui/charts/chart_wrappers/line', function(require){
      var LineChart = require('./new_ui/charts/chart_wrappers/line');
      new LineChart(el, values, labels);
    });
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:dimensiontemplates.nearme', function(event, el, units){
    require.ensure('./new_ui/modules/dimension_templates', function(require){
      var DimensionTemplates = require('./new_ui/modules/dimension_templates');
      new DimensionTemplates(el, units);
    });
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:photomanipulator.nearme', function(event, el){
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

  require.ensure('./ckeditor/init', function(require){
    require('./ckeditor/init');
  });
});

DNM.registerInitializer(function(){
  var run = function() {
    require.ensure('jquery.payment', function(require){
      require('jquery.payment');
      $('input[data-card-number]').eq(0).payment('formatCardNumber');
      $('input[data-card-code]').eq(0).payment('formatCardCVC');
    });
  };

  $(document).on('init:creditcardform.nearme', run);

  if ($('input[data-card-number], input[data-card-code]').length > 0) {
    run();
  }
});

DNM.registerInitializer(function(){
  $(document).on('init:shippingprofilescontroller.nearme', function(){
    require.ensure('./new_ui/controllers/shipping_profiles_controller', function(require){
      var ShippingProfilesController = require('./new_ui/controllers/shipping_profiles_controller');
      return new ShippingProfilesController('form.profiles_shipping_category_form');
    });
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
  function run(){
    var els = $('.unavailability');
    if (els.length === 0) {
      return;
    }

    require.ensure('./new_ui/forms/datepickers', function(require){
      var datepickers = require('./new_ui/forms/datepickers');
      els.on('cocoon:after-insert', function(e, insertedItem) {
        datepickers(insertedItem);
      });
    });
  }
  $(document).on('init:unavailability.nearme', run);
  run();
});

DNM.registerInitializer(function() {
  $('.schedule-exception-rules-container').on('cocoon:after-insert', function(e, insertedElement) {
    require.ensure('./new_ui/forms/hints', function(require) {
      var hints = require('./new_ui/forms/hints');
      hints(insertedElement);
    });
  });
});

DNM.registerInitializer(function(){

  function run(context) {
    var el = context.querySelector('.click-to-call-preferences');
    if (!el) {
      return;
    }

    require.ensure('./new_ui/modules/click_to_call_preferences', function(require){
      var ClickToCallPreferences = require('./new_ui/modules/click_to_call_preferences');
      return new ClickToCallPreferences(el);
    });
  }

  run(document);

  $('html').on('loaded:dialog.nearme', function(){
    run(document.querySelector('.dialog'));
  });
});


DNM.registerInitializer(function(){
  var ordersList = $('.orders-a');
  if (ordersList.length === 0) {
    return;
  }

  $(document).on('init:orders.nearme', function(){
    require.ensure('./new_ui/controllers/orders_controller', function(require){
      var OrdersController = require('./new_ui/controllers/orders_controller');
      new OrdersController(ordersList);
    });
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:paymentmodal.nearme', function(){
    require.ensure('./sections/dashboard/payment_modal_controller', function(require){
      var PaymentModalController = require('./sections/dashboard/payment_modal_controller');
      new PaymentModalController($('.dialog'));

      $(document).trigger('init:creditcardform.nearme');
    });
  });
});

DNM.registerInitializer(function(){
  var els = $('[data-expenses-overview]');
  if (els.length === 0) {
    return;
  }
  require.ensure('./new_ui/modules/order_items_index', function(require){
    var OrderItemsIndex = require('./new_ui/modules/order_items_index');
    els.each(function(){
      return new OrderItemsIndex(this);
    });
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:disableorderform.nearme', function(event, form) {
    $(form).find('input, textarea, button, select').attr('disabled','disabled');
  });
});

DNM.registerInitializer(function(){
  var conditionFields = document.querySelectorAll('[data-condition-field]');
  if (conditionFields.length < 0) {
    return;
  }

  require.ensure('form_components/condition_field', (require)=>{
    var ConditionField = require('form_components/condition_field');
    Array.prototype.forEach.call(conditionFields, (wrapper) => {
      new ConditionField(wrapper);
    });
  });
});

DNM.registerInitializer(function(){
  var form = $('#edit_user');
  if (form.length === 0) {
    return;
  }

  require.ensure('./sections/registrations/edit', function(require){
    var EditUserForm = require('./sections/registrations/edit');
    new EditUserForm(form);
  });
});

DNM.registerInitializer(function(){
  var els = $('#checkout-form, #list-space-flow-form');
  if (els.length === 0) {
    return;
  }
  require.ensure('./sections/draft_validation_controller', function(require){
    var DraftValidationController = require('./sections/draft_validation_controller');
    els.each(function(){
      return new DraftValidationController(this);
    });
  });
});


// New shared libraries
let sharedInitializers = require('shared-initializers');
sharedInitializers.forEach((initializer)=> DNM.registerInitializer(initializer));

DNM.run();
