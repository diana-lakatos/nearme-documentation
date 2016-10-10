module StubHelper
  def stub_image_url(image_url)
    stub_request(:get, image_url).to_return(status: 200, body: Rails.root.join('test', 'assets', 'foobear.jpeg'), headers: { 'Content-Type' => 'image/jpeg' })
  end

  def stub_local_time_to_return_hour(target, hour)
    time = mock
    time.stubs(:hour).returns(hour)
    target.stubs(:local_time).returns(time)
  end

  def stub_us_geolocation
    stub_request(:get, /maps.googleapis.com.*/).to_return(status: 200, body: GEOLOCATION_RESPONSE, headers: {})
  end
end

GEOLOCATION_RESPONSE = <<-eos
  {
   "results" : [
      {
         "address_components" : [
            {
               "long_name" : "United States",
               "short_name" : "US",
               "types" : [ "country", "political" ]
            }
         ],
         "formatted_address" : "United States",
         "geometry" : {
            "bounds" : {
               "northeast" : {
                  "lat" : 71.389888,
                  "lng" : -66.94539469999999
               },
               "southwest" : {
                  "lat" : 18.9110642,
                  "lng" : 172.4458955
               }
            },
            "location" : {
               "lat" : 37.09024,
               "lng" : -95.712891
            },
            "location_type" : "APPROXIMATE",
            "viewport" : {
               "northeast" : {
                  "lat" : 49.38,
                  "lng" : -66.94
               },
               "southwest" : {
                  "lat" : 25.82,
                  "lng" : -124.39
               }
            }
         },
         "place_id" : "ChIJCzYy5IS16lQRQrfeQ5K5Oxw",
         "types" : [ "country", "political" ]
      }
   ],
   "status" : "OK"
  }
eos
