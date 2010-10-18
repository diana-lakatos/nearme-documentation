var Search = {

  init: function(path) {

    this.hasInit = true;

    $(".pagination a").live("click", function(e) {

      var url = $(this).attr("href").replace(/^(.+)?\/search\/results/, "");
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
      } else if (e.parameters['query']) {
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
          query: address,
          lat: geometry['location'].lat(),
          lng: geometry['location'].lng(),
          types: result['types']
        };
        var bounds = geometry['bounds'];
        if(bounds) {
          var northeast = bounds.getNorthEast();
          var southwest = bounds.getSouthWest();
          query['bounds'] = {
            northeast: { lat: northeast.lat(), lng: northeast.lng() },
            southwest: { lat: southwest.lat(), lng: southwest.lng() }
          }
        }
        callback(query);
      }

    });

  }
 
}
