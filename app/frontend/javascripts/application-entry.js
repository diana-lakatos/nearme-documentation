'use strict';

var DNM = require('./common-app');

DNM.registerInitializer(function(){
  $('input[data-authenticity-token]').val($('meta[name="authenticity_token"]').attr('content'));
});

DNM.registerInitializer(function(){
  var SearchHomeController = require('./sections/search/home_controller');

  $('form.search-box').each(function(){
    return new SearchHomeController(this);
  });
});

DNM.registerInitializer(function(){
  $('#content').on('click', 'td.day .details.availability a', function(e) {
    e.stopPropagation();
    e.preventDefault();
    return false;
  });
});

DNM.registerInitializer(function(){
  /* centerSearchBoxOnHomePage */
  if($('.main-page').length === 0) {
    return;
  }

  function centerSearchBox(){
    var
      navbar_height = $('.navbar-fixed-top').height(),
      image_height = $('.dnm-page').height(),
      search_height = $('#search_row').height(),
      wood_box_height = $('.wood-box').height();
    $('#search_row').css('margin-top', (image_height)/2 - search_height/2 + navbar_height/2 - wood_box_height/2 + 'px');
  }

  $(window).on('resize.nearme', centerSearchBox);
  centerSearchBox();
});

DNM.registerInitializer(function(){
  $('.truncated-ellipsis').each(function() {
    $(this).click(function() {
      $(this).next('.truncated-text').toggleClass('hidden');
      if ($(this).parents('.accordion').length) {
        $('.accordion').css('height', 'auto');
      }
    });
  });
});

DNM.registerInitializer(function(){
  /* initializeModalClose */
  /* Re-enable form submit buttons on sign-in/sign-up modal close */
  $(document).on('click.nearme', '.sign-up-modal a.modal-close, .modal-overlay', function() {
    var need_reenable = $('.triggers-show-modal');
    if(need_reenable.length > 0) {
      $.rails.enableFormElements(need_reenable);
    }
  });
});

DNM.registerInitializer(function(){
  var loader = require('./components/wish_list_buttons/wish_list_button_loader');
  loader.load();

  $(document).on('load:searchResults.nearme', function(){
    loader.load();
  });

  $(document).on('rendered-search:ias.nearme', function(){
    loader.load();
  });
});

DNM.registerInitializer(function(){

  var urlUtil = require('./lib/utils/url');

  /* initializeUserBlogPagination */
  if ($('#infinite-scrolling').length === 0) {
    return;
  }

  $(window).on('scroll.nearme', function(){
    var next_page_path = $('.pagination .next_page').attr('href');
    if (next_page_path && $(window).scrollTop() > $(document).height() - $(window).height() - 60){
      $('.pagination').html('<img id="spinner" src="' + urlUtil.assetUrl('spinner.gif') + '" alt="Loading ..." title="Loading ..." />');
      $.getScript(next_page_path);
    }
  });
});

DNM.registerInitializer(function(){
  /* initializeCustomLiquidTags */
  $('select.locales_languages_select').change(function() {
    location.href = $(this).val();
  });
});

DNM.registerInitializer(function(){
  var els = $('#hero');
  var HomeController = require('./sections/home/controller');

  if (els.length === 0) {
    return;
  }

  els.each(function(){
    return new HomeController(this);
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:phonenumberfieldsform.nearme', function(event, context, options){
    options = options || {};
    require.ensure('./components/phone_numbers/phone_number_fields_form', function(require){
      var PhoneNumberFieldsForm = require('./components/phone_numbers/phone_number_fields_form');
      return new PhoneNumberFieldsForm(context, options);
    });
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
  var el = $('article#space');
  if (el.length === 0) {
    return;
  }

  require.ensure('./sections/space/controller', function(require){
    var SpaceController = require('./sections/space/controller');
    return new SpaceController(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('[data-back-to-search-results-link]');
  if (el.length === 0) {
    return;
  }

  require.ensure('./new_ui/modules/back_to_search', function(require){
    var BackToSearch = require('./new_ui/modules/back_to_search');
    return new BackToSearch(el);
  });
});

DNM.registerInitializer(function(){
  var els = $('[data-routelink]');
  if (els.length === 0) {
    return;
  }

  require.ensure('./components/route_link', function(require){
    var RouteLink = require('./components/route_link');
    els.each(function(){
      return new RouteLink($(this));
    });
  });
});


DNM.registerInitializer(function(){
  var els = $('[data-toggleable-booking-module]');
  if (els.length === 0) {
    return;
  }

  require.ensure('./sections/bookings/controller', function(require){
    var BookingsController = require('./sections/bookings/controller');
    els.each(function(){
      return new BookingsController(this);
    });
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:bookingscontroller.nearme', function(event, el){
    require.ensure(['./sections/bookings/controller', './components/custom_inputs', './components/custom_selects'], function(require){
      var
        BookingsController = require('./sections/bookings/controller'),
        CustomInputs = require('./components/custom_inputs'),
        CustomSelects = require('./components/custom_selects');

      new BookingsController(el);
      new CustomInputs(el);
      new CustomSelects(el);
    });
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:signinform.nearme', function(){
      require.ensure('./sections/signin_form', function(require){
          var SigninForm = require('./sections/signin_form');
          return new SigninForm($('#signup'));
      });
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:signupform.nearme', function(){
    require.ensure('./sections/signup_form', function(require){
      var SignupForm = require('./sections/signup_form');
      return new SignupForm($('#signup'));
    });
  });
});

DNM.registerInitializer(function(){
  var els = $('.order_shipments_shipping_rule_id');
  if (els.length === 0) {
    return;
  }
  require.ensure('./sections/checkout/delivery_controller', function(require){
    var DeliveryController = require('./sections/checkout/delivery_controller');
    els.closest('section[data-form-component-name]').each(function(){
      return new DeliveryController(this);
    });
  });
});

DNM.registerInitializer(function(){
  var els = $('#checkout-form .document-requirements');
  if (els.length === 0) {
    return;
  }
  require.ensure('./sections/checkout/payment_documents_controller', function(require){
    var PaymentDocumentsController = require('./sections/checkout/payment_documents_controller');
    return new PaymentDocumentsController(els);
  });
});

DNM.registerInitializer(function(){
  var form = $('#list-space-flow-form');
  if (form.length === 0) {
    return;
  }

  require.ensure([
    './sections/dashboard/location_controller',
    './sections/dashboard/listing_controller',
    './sections/space-wizard/space_wizard_list_form',
    './sections/categories'], function(require){
    var
      DashboardLocationController = require('./sections/dashboard/location_controller'),
      DashboardListingController = require('./sections/dashboard/listing_controller'),
      SpaceWizardSpaceForm = require('./sections/space-wizard/space_wizard_list_form'),
      CategoriesController = require('./sections/categories');

    new DashboardLocationController(form);
    new DashboardListingController(form);
    new SpaceWizardSpaceForm(form);
    new CategoriesController(form);
  });
});

DNM.registerInitializer(function(){
  var els = $('[data-behavior=address-autocomplete]');
  if (els.length === 0) {
    return;
  }

  require.ensure(['./sections/dashboard/address_controller'], function(require){
    var AddressController = require('./sections/dashboard/address_controller');
    return new AddressController(els.closest('form'));
  });
});


DNM.registerInitializer(function(){
  var form = $('#project_form');
  if (form.length === 0) {
    return;
  }

  require.ensure(['./sections/dashboard/address_controller'], function(require){
    var AddressController = require('./sections/dashboard/address_controller');
    return new AddressController(form);
  });
});

DNM.registerInitializer(function(){
  var form = $('#edit_user');
  if (form.length === 0) {
    return;
  }

  require.ensure([
    './sections/registrations/edit',
    './sections/categories'], function(require){
    var
      EditUserForm = require('./sections/registrations/edit'),
      CategoriesController = require('./sections/categories');

    new EditUserForm(form);
    new CategoriesController(form);
  });
});

DNM.registerInitializer(function(){
  var els = $('#reviews');
  if (els.length === 0) {
    return;
  }

  require.ensure(['./sections/registrations/user_reviews'], function(require){
    var UserReviews = require('./sections/registrations/user_reviews');
    return new UserReviews(els);
  });
});

DNM.registerInitializer(function(){
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

/* Search result pages */
DNM.registerInitializer(function(){
  $(document).on('init:list:searchresults.nearme', function(){
    require.ensure(['./sections/search/search_list_search_controller'], function(require){
      var
        SearchListSearchController = require('./sections/search/search_list_search_controller'),
        form = $('#listing_search form'),
        container = $('#content.search');
      return new SearchListSearchController(form, container);
    });
  });

  $(document).on('init:mixed:searchresults.nearme', function(){
    require.ensure(['./sections/search/search_mixed_controller'], function(require){
      var
        SearchMixedController = require('./sections/search/search_mixed_controller'),
        form = $('#listing_search form'),
        container = $('#results');
      return new SearchMixedController(form, container);
    });
  });

  $(document).on('init:products:searchresults.nearme', function(){
    require.ensure(['./sections/search/products_search_controller'], function(require){
      var
        ProductsSearchController = require('./sections/search/products_search_controller'),
        form = $('#search_form'),
        container = $('.search-view');
      return new ProductsSearchController(form, container);
    });
  });

  $(document).on('init:productslist:searchresults.nearme', function(){
    require.ensure(['./sections/search/products_list_search_controller'], function(require){
      var
        ProductsListSearchController = require('./sections/search/products_list_search_controller'),
        form = $('#listing_search form'),
        container = $('#content');

      return new ProductsListSearchController(form, container);
    });
  });

  $(document).on('init:productstable:searchresults.nearme', function(){
    require.ensure(['./sections/search/products_table_search_controller'], function(require){
      var
        ProductsTableSearchController = require('./sections/search/products_table_search_controller'),
        form = $('#form.search_results'),
        container = $('.search-view');

      return new ProductsTableSearchController(form, container);
    });
  });
});


DNM.registerInitializer(function(){
  var els = $('[data-seller-attachable]');
  if (els.length === 0) {
    return;
  }

  require.ensure(['./sections/seller_attachments_controller'], function(require){
    var SellerAttachmentsController = require('./sections/seller_attachments_controller');
    els.each(function(){
      return new SellerAttachmentsController($(this), { path: $(this).data('seller-attachment-path'), seller_attachable: $(this).data('seller-attachable') });
    });
  });
});

DNM.registerInitializer(function(){
  var els = $('[data-categories-controller]');
  if (els.length === 0) {
    return;
  }

  require.ensure(['./sections/categories'], function(require){
    var CategoriesController = require('./sections/categories');
    els.each(function(){
      var form = $(this).closest('form');
      return new CategoriesController(form);
    });
  });
});

DNM.registerInitializer(function(){
  var els = $('[data-reviews-controller]');
  if (els.length === 0) {
    return;
  }

  require.ensure(['./sections/reviews/controller'], function(require){
    var ReviewsController = require('./sections/reviews/controller');
    els.each(function(){
      return new ReviewsController($(this), { path: $(this).data('path'), reviewables: $(this).data('reviewables') });
    });
  });
});

DNM.registerInitializer(function(){
  var els = $('#support-faq');
  if (els.length === 0) {
    return;
  }

  require.ensure(['./sections/support_faq'], function(require){
    var SupportFaq = require('./sections/support_faq');
    return new SupportFaq(els);
  });
});

DNM.registerInitializer(function(){
  var link = $('#support-tickets-link');
  if (link.length === 0) {
    return;
  }

  require.ensure(['./sections/support_tickets'], function(require){
    var SupportTickets = require('./sections/support_tickets');
    return new SupportTickets(link);
  });
});

DNM.registerInitializer(function(){
  var el = $('#support-ticket-message-controller');
  if (el.length === 0) {
    return;
  }

  require.ensure(['./sections/support/ticket_message_controller'], function(require){
    var SupportTicketMessageController = require('./sections/support/ticket_message_controller');
    return new SupportTicketMessageController(el);
  });
});

DNM.registerInitializer(function(){
  var el = $('.booking-module-container');
  if (el.length === 0) {
    return;
  }

  el.on('click', '.pricing-tabs a', function(e){
    e.preventDefault();
    $(e.target).closest('a').tab('show');
  });
  el.find('.pricing-tabs a.possible:first').click();
});

DNM.registerInitializer(function(){
  var el = $('[data-shipping-country-controller]');
  if (el.length === 0) {
    return;
  }

  var
    billingCheck = $('#order_use_billing'),
    shippingWrapper = $('#shipping-address');

  function toggleShippingAddress() {
    shippingWrapper.toggle(!billingCheck.prop('checked'));
  }

  billingCheck.on('click', function() {
    toggleShippingAddress();
  });

  function loadStatesForCountry(country_id, url, bill_address) {
    $.get(url, { country_id: country_id, bill_address: bill_address });
  }

  $('#order_billing_address_attributes_country_id').on('change', function() {
    loadStatesForCountry($(this).val(), $(this).data('get-states-url'),1);
  });

  $('#order_shipping_address_attributes_country_id').on('change', function() {
    loadStatesForCountry($(this).val(), $(this).data('get-states-url'), 0);
  });

  toggleShippingAddress();
});

DNM.registerInitializer(function(){
  $(document).on('init:sellerattachmentaccesslevelselector.nearme', function(event, el){
    el = el || document;
    require.ensure('./components/seller_attachment_access_level_selector', function(require){
      var SellerAttachmentAccessLevelSelector = require('./components/seller_attachment_access_level_selector');
      return new SellerAttachmentAccessLevelSelector(el);
    });
  });
});

DNM.registerInitializer(function(){
  var el = $('a[data-save-search]');
  if (el.length === 0) {
    return;
  }

  require.ensure('./sections/search/save_search_controller', function(require){
    var SearchSaveSearchController = require('./sections/search/save_search_controller');
    return new SearchSaveSearchController();
  });
});

DNM.registerInitializer(function(){
  var el = $('#checkout-form');
  if (el.length === 0) {
    return;
  }

  require.ensure('./sections/reservations/review_controller', function(require){
    var ReservationReviewController = require('./sections/reservations/review_controller');
    return new ReservationReviewController(el);
  });
});

DNM.registerInitializer(function(){
  var form = $('#cart');
  if (form.length === 0) {
    return;
  }

  $('select[name^=quantity]').on('change', function() {
    form.submit();
  });
});


DNM.registerInitializer(function(){
  var dateInput = $('[data-jquery-datepicker]');
  if (dateInput.length === 0) {
    return;
  }

  require.ensure(['./sections/search/time_and_datepickers', './new_ui/forms/timepickers'], function(require){
    var SearchTimeAndDatepickers = require('./sections/search/time_and_datepickers');
    return new SearchTimeAndDatepickers(dateInput);
  });
});


DNM.registerInitializer(function(){
  $(document).on('init:mobileNumberForm.nearme', function() {
    var container = $('div[data-phone-fields-container]');

    require.ensure(['./new_ui/modules/phone_numbers', './new_ui/forms/selects'], function(require){
      var PhoneNumbers = require('./new_ui/modules/phone_numbers'),
        customSelects = require('./new_ui/forms/selects');

      customSelects(container);
      return new PhoneNumbers(container);
    });
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:homepageranges.nearme', function() {
    $('[name="start_date"]').each(function(index, element) {
      if($(element).datepicker && !$(element).attr('data-no-default')) {
        $(element).datepicker('setDate', new Date());
      }
    });

    $('[name="end_date"]').each(function(index, element) {
      if($(element).datepicker && !$(element).attr('data-no-default')) {
        $(element).datepicker('setDate', 1);
      }
    });
  });
});

DNM.registerInitializer(function(){
  $( document ).on('modal-shown.nearme', function(e, containerElement) {
    $(containerElement).find('input[data-authenticity-token]').val($('meta[name="authenticity_token"]').attr('content'));
  });
});

DNM.registerInitializer(function(){
  var wrapper = document.querySelector('.social-buttons-wrapper');

  if(!wrapper) {
    return;
  }

  require.ensure(['./vendor/socialite', './new_ui/modules/social_buttons'], function(require){
    var SocialButtons = require('./new_ui/modules/social_buttons');
    require('./vendor/socialite');

    return new SocialButtons(wrapper, window.Socialite);
  });
});

DNM.registerInitializer(function(){
  $(document).on('init:tooltips.nearme', function(e, containerElement) {
    $(containerElement).find('[data-toggle="tooltip"]').tooltip({
      placement: 'right'
    });
  });
});

let sharedInitializers = require('shared-initializers');
sharedInitializers.forEach((initializer)=> DNM.registerInitializer(initializer));

DNM.run();
