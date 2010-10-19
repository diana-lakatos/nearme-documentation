var Search = {

  init: function(path, serverResults) {

    if(serverResults) return false;

    this.hasInit = true;

    $(".pagination a").live("click", function(e) {

      var url = $(this).attr("href").replace(/^(.+)?\/search/, "");
      $.address.value(url);

      // scroll to top
      if(document.documentElement && document.documentElement.scrollTop)
        document.documentElement.scrollTop = 0;
      else
        document.body.scrollTop = 0;

      return false;
    });

    $.address.change(function(e) {  

      var container = $("#results");
      var loading = container.data("loader");
      if(loading) {
        container.html(loading);
      } else {
        container.data("loader", container.html());
      }

      var address = e.parameters['address'];

      if(address) {
        Search.search(address);
      } else if (e.parameters['lat'] && e.parameters['lng']) {
        var input = $("#search");
        if(!input.val()) {
          var l = unescape(e.parameters['q']).replace(/\+/g, ' ');
          input.val(l);
        }
        $.ajax({
          url: path,
          method: "POST",
          data: e.parameters,
          success: function(html) {
            container.html(html);
          }
        })
      } else {
        container.html("<p>Please enter a city or address</p>");
      }

    });

  },

  search: function(val) {

    if(this.hasInit) {
      this.geocode(val, function(query) {
        $.address.value('?' + $.param(query));
      });
    } else {
      window.location = "/search#/?address=" + val;
    }

    return false;

  },

  geocode: function(address, callback) {

    var geocoder = new google.maps.Geocoder();

    geocoder.geocode({ address: address }, function(results, status) {

      var result = results[0];

      if(!result) {

        alert("nothing found");

      } else {

        var geometry = result['geometry'];
        var query = {
          q: address,
          lat: geometry['location'].lat(),
          lng: geometry['location'].lng()
        };

        var t = result['types'];
        var bounds = geometry['bounds'];
        if( bounds && (t[0] == "country" && t[1] == "political") || (t[0] == "administrative_area_level_1" && t[1] == "political") ) {
          var northeast = bounds.getNorthEast();
          var southwest = bounds.getSouthWest();
          query['nx'] = northeast.lat();
          query['ny'] = northeast.lng();
          query['sx'] = southwest.lat();
          query['sy'] = southwest.lng();
        }

        callback(query);

      }

    });

  }
 
}
