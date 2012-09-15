// Desks Near Me
//
// Require legacy jQuery dependent code first
//= require ./vendor/jquery-1.4.1.js
//= require ./vendor/jquery.overlay.js
//= require ./vendor/jquery-ui-1.8.23.custom.min.js
//= require ./vendor/jquery.address-1.3.min
//= require search
//* require ./vendor/fancybox/jquery.fancybox-1.3.1.pack.js
//
// Require new jQuery to override (NB: This is so HAX)
//= require ./vendor/jquery
//= require ./vendor/rails
//= require ./vendor/modernizr.js
//= require ./vendor/jquery.cookie.js
//= require tile.stamen.js
//
//= require_self

// FIXME: Hax to initialize jQuery UI on 2 versions of JQuery temporaryily
initializeJQueryUI(jQuery);

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


function getUserLocationForSearch() {
  var searchForm      = $("form#listing_search");
  if(searchForm.length >= 1) {
    var currentLocation = $.cookie("currentLocation");

    if(currentLocation)
      setSearchFormToLocation(searchForm, currentLocation);
    else {
      if(Modernizr.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
          var geocoder = new google.maps.Geocoder();
          geocoder.geocode({ address: position.coords.latitude + "," + position.coords.longitude }, function(results, status) {
            var components = results[0].address_components,
                city = null,
                country = null;
            for(var i = 0, l = components.length; i < l; i++) {
               var types = components[i]['types'];
               if(types.indexOf('locality') >= 0 && types.indexOf('political') >= 0) city = components[i]['long_name'];
               if(types.indexOf('country') >= 0 && types.indexOf('political') >= 0) country = components[i]['long_name'];
            }
            if(city) {
              currentLocation = city + ", " + country;
              $.cookie("currentLocation", currentLocation);
              setSearchFormToLocation(searchForm, currentLocation);
            }
          });
        });
      }
    }
  }
}

function setSearchFormToLocation(form, location) {
  var input  = $("input:text", form),
      button = $("input.geolocation", form);

  button.addClass("active").attr("data-geo-val", location).click(function(){
    input.val($(this).attr("data-geo-val")).focus();
  });

  if(input.val() == "" && !Search.hasInit)
    button.click();
}

function doListingGoogleMaps() {
  var locations = $(".column.map address"),
      map       = null;

  $.each(locations, function(index, location) {
    location        = $(location);
    var latlng      = new google.maps.LatLng(location.attr("data-lat"), location.attr("data-lng"));

    if(!map) {
      var layer = "toner";
      map = new google.maps.Map(document.getElementById("map"), {
        zoom: 15,
        mapTypeId: layer,
        mapTypeControl: false,
        center: latlng,
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

function doPhotoFancyBox() {
  $(".fancy-photos a:has(img), .fancy-photos [href$=.jpg], .fancy-photos a[href$=.png], .fancy-photos a[href$=.gif]")
    .attr("rel", "photos").fancybox({
      transitionIn: "elastic",
      transitionOut: "elastic",
      titlePosition: "over",
      padding: 0
    });
}

$(function(){
//  doPhotoFancyBox();
  doInlineReservation();
  doListingGoogleMaps();
  getUserLocationForSearch();
  $("#listing_search").submit(function() {
    Search.search($("#search").val());
    return false;
  });
});
