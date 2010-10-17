$(function(){
  $(".fancy-photos a:has(img), .fancy-photos [href$=.jpg], .fancy-photos a[href$=.png], .fancy-photos a[href$=.gif]")
    .attr("rel", "photos").fancybox({
      transitionIn: "elastic",
      transitionOut: "elastic",
      titlePosition: "over",
      padding: 0
    });
    
  if(Modernizr.geolocation) {
    var form = $("form.big_search");
    if(form.length == 1) {
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
            $("input.geolocation", form).addClass("active").attr("geo-val", city + ", " + country).click(function(){
              var form = $(this).parents('form').first();
              $("input:text", form).val($(this).attr("geo-val")).focus();
            });
          }
        });
      });
    }
  }
});
