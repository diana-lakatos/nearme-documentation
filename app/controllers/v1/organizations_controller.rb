class V1::OrganizationsController < V1::BaseController
  def index
    render json: Organization.all
  end
end
