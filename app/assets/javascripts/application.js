// Desks Near Me
//
//= require jquery
//= require ./vendor/jquery-ui-1.9.2.custom.min
//= require ./vendor/jquery.overlay
//= require ./vendor/jquery.address-1.3.min
//= require ./vendor/jquery.ui.touch-punch
//= require ./vendor/customSelect.jquery
//= require bootstrap
//= require ./vendor/rails
//= require ./vendor/modernizr
//= require ./vendor/jquery.cookie
//= require ./vendor/jquery.popover-1.1.2
//= require ./vendor/jquery.payment
//= require ./vendor/asevented
//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink
//= require mustache
//= require handlebars.runtime
//= require chosen-jquery
//
//
//= require_self
// Helper modules, etc.
//= require_tree ./lib
//= require_tree ./app/models
//= require_tree ./app/templates
//= require_tree ./app
//
// Standard components
//= require_tree ./components
//
// Sections
//= require_tree ./sections

window.DNM = {
  UI: {},
  initialize : function() {
    this.initializeAjaxCSRF();
    this.initializeComponents();
    this.initializeModals();
    this.initializeTooltips();
    this.initializeCustomSelects();
  },

  initializeModals: function() {
    Modal.listen();
  },

  initializeComponents: function(scope) {
    Multiselect.initialize(scope);
    Flash.initialize(scope);
    Accordian.initialize(scope);
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
    $('.custom-select').chosen()
    $('.chzn-choices input').focus(function(){
        $(this).parent().parent().addClass('chzn-choices-active')
    }).blur(function(){
        $(this).parent().parent().removeClass('chzn-choices-active')
    })
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
      map = new google.maps.Map(document.getElementById("map"), {
        zoom: 13,
        mapTypeId: layer,
        mapTypeControl: false,
        center: latlng
      });
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
