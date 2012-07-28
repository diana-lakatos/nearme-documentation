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
          latitude:  request.location.latitude  - 0.25,
          longitude: request.location.longitude - 0.25
        },
        :end => {
          latitude:  request.location.latitude  + 0.25,
          longitude: request.location.longitude + 0.25
        }
      },
      location: {
        name:      "#{request.location.city}, #{request.location.state_code}",
        city:      request.location.city,
        region:    request.location.state,
        country:   request.location.country_code,
        latitude:  request.location.latitude,
        longitude: request.location.longitude
      }
    }
  end
end
