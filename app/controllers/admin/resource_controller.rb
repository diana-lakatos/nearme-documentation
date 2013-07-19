# An abstract controller class that provides common behaviour for basic
# CRUD for resources.
class Admin::ResourceController < Admin::BaseController
  inherit_resources

  protected

  def collection
    end_of_association_chain.paginate(:page => params[:page])
  end
end

