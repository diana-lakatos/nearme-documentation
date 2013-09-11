class V1::IplookupController < V1::BaseController

  def index
    render json: iplookup_hash
  end

  protected

  def iplookup_hash
    {
      ip: request.remote_ip,
      boundingbox: {
        start: {
          latitude:  request.location.andand.latitude.to_f  - 0.25,
          longitude: request.location.andand.longitude.to_f - 0.25
        },
        :end => {
          latitude:  request.location.andand.latitude.to_f  + 0.25,
          longitude: request.location.andand.longitude.to_f + 0.25
        }
      },
      location: {
        name:      "#{request.location.andand.city}, #{request.location.andand.state_code}",
        city:      request.location.andand.city,
        region:    request.location.andand.state,
        country:   request.location.andand.country_code,
        latitude:  request.location.andand.latitude,
        longitude: request.location.andand.longitude
      }
    }
  end
end
