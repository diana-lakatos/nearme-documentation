function setSearchFormToLocation(form, location) {
  var input  = $("input:text", form),
      button = $("input.geolocation", form);
  
  button.addClass("active").attr("data-geo-val", location).click(function(){
    input.val($(this).attr("data-geo-val")).focus();
  });
  
  if(input.val() == "")
    button.click();
}

$(function(){
  $(".fancy-photos a:has(img), .fancy-photos [href$=.jpg], .fancy-photos a[href$=.png], .fancy-photos a[href$=.gif]")
    .attr("rel", "photos").fancybox({
      transitionIn: "elastic",
      transitionOut: "elastic",
      titlePosition: "over",
      padding: 0
    });


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
});
