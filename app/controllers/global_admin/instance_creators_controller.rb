class GlobalAdmin::InstanceCreatorsController < GlobalAdmin::ResourceController

  def index
    @instance_creator = InstanceCreator.new
    super
  end

  private

  def instance_creator_params
    params.require(:instance_creator).permit(:email, :created)
  end

  protected

  def collection_search_fields
    %w(email)
  end

end
