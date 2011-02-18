function getUserLocationForSearch() {
  var searchForm      = $("form.big_search");
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

function doWorkplaceGoogleMaps() {
  var locations = $("aside address, aside details.address"),
      map       = null;
      
  
  $.each(locations, function(index, location) {
    location        = $(location);
    var latlng      = new google.maps.LatLng(location.attr("data-lat"), location.attr("data-lng"));
    
    if(!map) {
      map = new google.maps.Map(document.getElementById("map"), {
        zoom: 13,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControl: false,
        center: latlng
      });
    }
    
    var image       = location.attr("data-marker");
    var beachMarker = new google.maps.Marker({
      position: latlng,
      map: map,
      icon: image
    });
  });
}

function doInlineBooking() {
  $("td.day details.availability a").click(function(e){
    e.stopPropagation();
    var overlay = $("body").overlay({ ajax: $(this).attr("href"), position: { my: "top", at: "bottom", of: $(this).parents('td') }, html: 'Working&hellip;', 'class': "context" });
    $(".overlay-container a.cancel").live("click", function(e){
      e.stopPropagation();
      $(".overlay-container").overlay('close');
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
  doPhotoFancyBox();
  doInlineBooking();
  doWorkplaceGoogleMaps();
  getUserLocationForSearch();
  $("#workplace_search").submit(function() {
    Search.search($("#search").val());
    return false;
  });
});
