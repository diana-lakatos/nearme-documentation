class V1::LocationsController <  V1::BaseController
  before_filter :require_authentication

  expose :location

  def list
    @locations = current_user.default_company.locations.select('id,name')
  end
end
