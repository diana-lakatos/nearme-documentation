// Desks Near Me
//
//= require jquery
//= require jquery_ujs
//= require javascript_module
//= require ./vendor/jquery-ui-1.10.4.custom.min.js
//= require ./vendor/jquery.ui.touch-punch
//= require ./vendor/customSelect.jquery
//= require bootstrap
//= require ./instance_admin/jquery.jstree
//= require ./vendor/modernizr
//= require ./vendor/jquery.cookie
//= require ./vendor/jquery.popover-1.1.2
//= require ./vendor/jquery.payment
//= require ./vendor/jquery.limiter
//= require ./vendor/asevented
//= require ./vendor/detect-mobile-browser
//= require ./vendor/infobox
//= require ./vendor/jquery.scrollto
//= require ./vendor/jQueryRotate
//= require ./vendor/placeholder
//= require ./vendor/jquery.ias
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
//= require user_blog/pagination
//= require select2
//= require jquery-fileupload/basic
//= require jquery_nested_form
//= require js-routes
//= require custom_liquid_tags
//= require dimensions_templates_select_behaviors
//= require dimensions_templates_admin_behaviors
//= require cocoon
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
//= require_tree ./sections
//
//= require ./vendor/bootstrap-modal-fullscreen
//= require bootstrap-switch

window.DNM = {
  UI: {},
  initialize : function() {
    this.initializeAjaxCSRF();
    this.initializeComponents();
    this.initializeIcui();
    this.initializeBootstrapSwitch();
    this.initializeTooltips();
    this.initializeCustomSelects($('body'));
    this.initializeCustomInputs();
    this.initializeBrowsersSpecificCode();
    this.centerSearchBoxOnHomePage();
    this.setFooterPushHeight();
    this.setRotuesPrefix();
    this.initializeSearchBox();
  },

  setRotuesPrefix: function() {
    if (I18n.locale.length > 0) {
      Routes.options.prefix = "/" + I18n.locale;
    }
  },

  initializeIcui: function() {
    var icui = $("input[type=hidden].icui").icui();
  },

  initializeBootstrapSwitch: function() {
    $('.switch input:visible')['bootstrapSwitch']();
  },

  initializeCustomInputs: function() {
    CustomInputs.initialize();
  },

  initializeComponents: function(scope) {
    Multiselect.initialize(scope);
    Flash.initialize(scope);
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
    container.find('select').not('.select2, .time-wrapper select, .custom-select, .recurring_select, .ordinary-select, .selectpicker').customSelect();
    container.find('.customSelect').not('.checkout-select, .no-icon').append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>').closest('.controls').css({'position': 'relative'});
    container.find('.customSelect').siblings('select').css({'margin': '0px', 'z-index': 1 });

    container.find('.custom-select').chosen()
    container.find('.chzn-container-single a.chzn-single div').hide();
    container.find('.chzn-container-single, .chzn-container-multi').append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>');
    container.find('.chzn-choices input').focus(function(){
      $(this).parent().parent().addClass('chzn-choices-active');
    }).blur(function(){
      $(this).parent().parent().removeClass('chzn-choices-active');
    })

    container.find('.select2').select2({
      minimumResultsForSearch: 20
    });
  },

  initializeBrowsersSpecificCode: function() {
    this.fixInputIconBackgroundTransparency();  // fix icon in input transparency in IE8
    this.fixMobileFixedPositionAfterInputFocus();
  },

  initializeSearchBox: function(){
    $('form.search-box').each(function(){
      new Search.HomeController($(this));
    });
  },

  centerSearchBoxOnHomePage: function() {
    if($('.main-page').length > 0){
      centerSearchBox();
      if (!window.addEventListener) {
          window.attachEvent('resize', function(event){
            centerSearchBox();
          });
      }
      else {
        window.addEventListener('resize', function(event){
          centerSearchBox();
        });
      }
    }
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
      $('.footer-push').height($('.footer-wrapper').outerHeight());
    }

    $(window).resize(function(){
      if ($('.footer-wrapper').length > 0) {
        $('.footer-push').height($('.footer-wrapper').outerHeight());
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

function doListingGoogleMaps() {
  return;
  var locations = $(".map address"),
      map       = null;

  $.each(locations, function(index, location) {
    location        = $(location);
    var latlng      = new google.maps.LatLng(location.attr("data-lat"), location.attr("data-lng"));

    if(!map) {
      var layer = "toner";
      map = SmartGoogleMap.getMap(document.getElementById("map"), {
        zoom: 13,
        mapTypeId: layer,
        mapTypeControl: false,
        center: latlng
      })
      map.mapTypes.set(layer, new google.maps.StamenMapType(layer));
    }

    var image       = location.attr("data-marker");
    var beachMarker = new google.maps.Marker({
      position: latlng,
      map: map,
      icon: image
    });
  });
}

function doInlineReservation() {
  $("#content").on("click", "td.day .details.availability a", function(e) {
    e.stopPropagation();
    e.preventDefault();
    return false;
  });
}

$(function(){
  doInlineReservation();
  doListingGoogleMaps();
});

$(function() {
  var ellipses = $(".truncated-ellipsis")

  $.each(ellipses, function() {
    $(this).click(function() {
      $(this).next('.truncated-text').toggleClass('hidden');
      // If within an accordion, i.e. if has a parent of class accordion
      if ($(this).parents('.accordion').length) {
        $('.accordion').css('height', 'auto');
      }
    });
  });
});

$(function(){
    $.extend($.fn.disableTextSelect = function() {
        return this.each(function(){
            if($.browser.mozilla){//Firefox
                $(this).css('MozUserSelect','none');
            }else if($.browser.msie){//IE
                $(this).bind('selectstart',function(){return false;});
            }else{//Opera, etc.
                $(this).mousedown(function(){return false;});
            }
        });
    });
    $('.no-select').disableTextSelect();//No text selection on elements with a class of 'noSelect'
});

function centerSearchBox(){
  navbar_height = $('.navbar-fixed-top').height();
  image_height = $('.dnm-page').height();
  search_height = $('#search_row').height()
  wood_box_height = $('.wood-box').height()
  $('#search_row').css('margin-top', (image_height)/2 - search_height/2 + navbar_height/2 - wood_box_height/2 + 'px');
}
