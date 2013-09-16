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
          latitude:  request.location.try(:latitude).to_f  - 0.25,
          longitude: request.location.try(:longitude).to_f - 0.25
        },
        :end => {
          latitude:  request.location.try(:latitude).to_f  + 0.25,
          longitude: request.location.try(:longitude).to_f + 0.25
        }
      },
      location: {
        name:      "#{request.location.try(:city)}, #{request.location.try(:state_code)}",
        city:      request.location.try(:city),
        region:    request.location.try(:state),
        country:   request.location.try(:country_code),
        latitude:  request.location.try(:latitude),
        longitude: request.location.try(:longitude)
      }
    }
  end
end
