class GlobalAdmin::VersionsController < GlobalAdmin::BaseController
  before_filter :set_instance, :except => [:destroy]
  before_filter :set_instance_view
  before_filter :set_version, :except => [:index]

  def index
    @versions = @instance_view.versions
  end

  def show
    @instance_view = @version.reify
  end

  def rollback
    @instance_view = @version.reify
    if @instance_view.save
      flash[:success] = "Page has been successfully restored to previous version."
    else
      flash[:error] = "Unable to restore page to previus version"
    end
    redirect_to [:admin, @instance, @instance_view]
  end

  private

  def set_instance
    @instance = Instance.find(params[:instance_id])
  end

  def set_instance_view
    @instance_view = InstanceView.find(params[:instance_view_id])
  end

  def set_version
    @version = @instance_view.versions.find(params[:id])
  end

end
