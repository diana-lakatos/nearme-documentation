// Desks Near Me
//
//= require jquery
//= require jquery_ujs
//= require ./vendor/jquery-ui-1.9.2.custom.min
//= require ./vendor/jquery.overlay
//= require ./vendor/jquery.ui.touch-punch
//= require ./vendor/customSelect.jquery
//= require bootstrap
//= require ./vendor/modernizr
//= require ./vendor/jquery.cookie
//= require ./vendor/jquery.popover-1.1.2
//= require ./vendor/jquery.payment
//= require ./vendor/asevented
//= require ./vendor/detect-mobile-browser
//= require ./vendor/infobox
//= require ./vendor/jquery.scrollto
//= require ./vendor/jQueryRotate
//= require ./vendor/placeholder
//= require ./vendor/jquery.ias
//= require ./vendor/ZeroClipboard
//= require ./vendor/markerclusterer
//= require jquery-fileupload/basic
//= require history_jquery
//= require ./vendor/underscore
//= require chosen-jquery
//= require chart
//= require jcrop
//= require spectrum
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

window.DNM = {
  UI: {},
  initialize : function() {
    this.initializeAjaxCSRF();
    this.initializeComponents();
    this.initializeModals();
    this.initializeTooltips();
    this.initializeCustomSelects();
    this.initializeCustomInputs();
    this.initializeBrowsersSpecificCode();
    this.centerSearchBoxOnHomePage();
  },

  initializeModals: function() {
    Modal.listen();
  },

  initializeCustomInputs: function() {
    CustomInputs.initialize();
  },

  initializeComponents: function(scope) {
    Multiselect.initialize(scope);
    Flash.initialize(scope);
    Accordian.initialize(scope);
    Clipboard.initialize(scope);
    Photo.Initializer.initialize(scope);
    NavigationBar.initialize(scope);
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

  initializeCustomSelects: function(){
    $('select').not('.time-wrapper select, .custom-select').customSelect();
    $('.customSelect').append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>').closest('.controls').css({'position': 'relative'});
    $('.customSelect').siblings('select').css({'margin': '0px', 'z-index': 1 });

    $('.custom-select').chosen()
    $('.chzn-container-single a.chzn-single div').hide();
    $('.chzn-container-single, .chzn-container-multi').append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>');
    $('.chzn-choices input').focus(function(){
      $(this).parent().parent().addClass('chzn-choices-active');
    }).blur(function(){
      $(this).parent().parent().removeClass('chzn-choices-active');
    })
  },

  initializeBrowsersSpecificCode: function() {
    this.fixInputIconBackgroundTransparency();  // fix icon in input transparency in IE8 
    this.fixMobileFixedPositionAfterInputFocus(); 
  },

  centerSearchBoxOnHomePage: function() {
    if($('.white-label-main-page').length > 0){
      centerSearchBox();
      window.addEventListener('resize', function(event){
        centerSearchBox();
      });
    }
  },

  fixInputIconBackgroundTransparency: function() {
    if ($.browser.msie  && parseInt($.browser.version, 10) === 8) {
      $('.input-icon-holder input').live("focus", function() {
        $(this).parents('.input-icon-holder').eq(0).find('span').eq(0).css('background', '#f0f0f0');
      })
      $('.input-icon-holder input').live("blur", function() {
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
    var overlay = jQueryLegacy("body").overlay({ ajax: $(this).attr("href"), position: { my: "top", at: "bottom", of: $(this).parents('td') }, html: 'Working&hellip;', 'class': "context" });
    $(".overlay-container a.cancel").live("click", function(e){
      e.stopPropagation();
      jQueryLegacy(".overlay-container").overlay('close');
      return false;
    });
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

String.prototype.hashCode = function(){
    var hash = 0, i, char;
    if (this.length == 0) return hash;
    for (i = 0; i < this.length; i++) {
        char = this.charCodeAt(i);
        hash = ((hash<<5)-hash)+char;
        hash = hash & hash; // Convert to 32bit integer
    }
    return hash;
};
