// Desks Near Me
//
//= require jquery
//= require jquery_ujs
//= require ./vendor/jquery-ui-1.10.4.custom.min.js
//= require ./vendor/jquery.ui.touch-punch
//= require ./vendor/customSelect.jquery
//= require ./instance_admin/bootstrap
//= require ./instance_admin/bootstrap-select
//= require ./instance_admin/jquery.jstree
//= require select2
//= require ./vendor/modernizr
//= require ./vendor/jquery.cookie
//= require ./vendor/jquery.popover-1.1.2
//= require ./vendor/jquery.limiter
//= require ./vendor/asevented
//= require ./vendor/detect-mobile-browser
//= require ./vendor/jquery.scrollto
//= require ./vendor/jQueryRotate
//= require ./vendor/placeholder
//= require ./vendor/jquery.ias
//= require ./vendor/ZeroClipboard
//= require ./vendor/markerclusterer
//= require ./vendor/icui
//= require ./vendor/strftime
//= require ./vendor/jstz
//= require recurring_select
//= require history_jquery
//= require ./vendor/underscore
//= require chosen-jquery
//= require ./vendor/Chart
//= require jcrop
//= require spectrum
//= require ./vendor/jquery.inview
//= require ckeditor/basepath
//= require ckeditor/init
//= require vendor/jquery.raty
//= require ./advanced_closest
//= require jquery-fileupload/basic
//= require jquery_nested_form
//= require js-routes
//= require custom_liquid_tags
//
//
//= require_self
// Helper modules, etc.
//= require_tree ./ext
//= require_tree ./lib
//
// Standard components
//= require_directory ./components/lib
//= require_directory ./components
//
// Sections
//= require ./sections/dashboard
//= require ./sections/search
//= require ./sections/search_instance_admin
//= require ./sections/company_form
//= require ./sections/setup_nested_form
//= require ./sections/registrations/edit
//= require ./sections/support
//= require ./sections/categories
//= require ./sections/support/attachment_form
//= require ./sections/support/ticket_message_controller
//= require ./sections/approval_request_attachments_controller
//= require_tree ./sections/buy_sell
//= require_tree ./sections/dashboard
//
//= require ./vendor/bootstrap-modal-fullscreen
//= require bootstrap-switch

window.DNM = {
  UI: {},
  initialize : function() {
    this.initializeAjaxCSRF();
    this.initializeComponents();
    this.initializeIcui();
    this.initializeBootstrap();
    this.initializeTooltips();
    this.initializeCustomSelects($('body'));
    this.initializeCustomInputs();
    this.initializeBrowsersSpecificCode();
    this.setFooterPushHeight();
  },

  initializeIcui: function() {
    var icui = $("input[type=hidden].icui").icui();
  },

  initializeBootstrap: function() {
    $('.selectpicker').selectpicker({'iconShow': false});
    $('.switch input:visible')['bootstrapSwitch']();
  },

  initializeCustomInputs: function() {
    CustomInputs.initialize();
  },

  initializeComponents: function(scope) {
    Multiselect.initialize(scope);
    Flash.initialize(scope);
    Clipboard.initialize(scope);
    Limiter.initialize(scope);
    Fileupload.initialize(scope);
  },

  initializeAjaxCSRF: function() {
    $.ajaxSetup({
      beforeSend: function(xhr) {
        xhr.setRequestHeader(
          'X-CSRF-Token',
           $('meta[name="csrf-token"]').attr('content')
        );
      }
    });
  },

  initializeTooltips: function(){
    $('[rel=tooltip]').tooltip()
  },

  initializeCustomSelects: function(container){
    container.find('select').not('.time-wrapper select, .custom-select, .recurring_select, .selectpicker, .icui select, .unstyled-select').customSelect();
    container.find('.customSelect').append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>').closest('.controls').css({'position': 'relative'});
    container.find('.customSelect').siblings('select').css({'margin': '0px', 'z-index': 1 });

    container.find('.custom-select').chosen()
    container.find('.chzn-container-single a.chzn-single div').hide();
    container.find('.chzn-container-single, .chzn-container-multi').append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>');
    container.find('.chzn-choices input').focus(function(){
      $(this).parent().parent().addClass('chzn-choices-active');
    }).blur(function(){
      $(this).parent().parent().removeClass('chzn-choices-active');
    })
  },

  initializeBrowsersSpecificCode: function() {
    this.fixInputIconBackgroundTransparency();  // fix icon in input transparency in IE8
    this.fixMobileFixedPositionAfterInputFocus();
  },

  fixInputIconBackgroundTransparency: function() {
    if ($.browser.msie  && parseInt($.browser.version, 10) === 8) {
      $(document).on('focus', '.input-icon-holder input', function() {
        $(this).parents('.input-icon-holder').eq(0).find('span').eq(0).css('background', '#f0f0f0');
      })
      $(document).on('blur', '.input-icon-holder input', function() {
        $(this).parents('.input-icon-holder').eq(0).find('span').eq(0).css('background', '#e6e6e6');
      });
    }
  },

  fixMobileFixedPositionAfterInputFocus: function() {
    if (this.isiOS()) {
      jQuery('input, select, textarea').on('focus', function(e) {
          $('body').addClass('mobile-fixed-position-fix');
      }).on('blur', function(e) {
        $('body').removeClass('mobile-fixed-position-fix');

        setTimeout(function() {
          $(window).scrollTop($(window).scrollTop() + 1);
        }, 100);
      });
    }
  },

  setFooterPushHeight: function() {
    if ($('.footer-wrapper').length > 0) {
      $('.footer-push').height($('.footer-wrapper').height());
    }

    $(window).resize(function(){
      if ($('.footer-wrapper').length > 0) {
        $('.footer-push').height($('.footer-wrapper').height());
      }
    })
  },

  isMobile: function() {
    return $.browser.mobile;
  },

  isDesktop: function() {
    return !this.isMobile();
  },

  isiOS: function() {
    return navigator.userAgent.match(/(iPod|iPhone|iPad)/);
  }
}

$(function() {
  DNM.initialize()
})

jQuery.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})

$(document).on('click', 'a[rel=submit]', function(e) {
  var form = $(this).closest('form');
  if (form.length > 0) {
    e.preventDefault();
    form.submit();
    return false;
  }
});
