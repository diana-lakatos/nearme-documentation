class GlobalAdmin::InstanceViewsController < GlobalAdmin::BaseController
  before_filter :set_instance, :except => [:destroy]
  before_filter :set_instance_view, :only => [:edit, :update, :destroy]

  def index
    @instance_views = InstanceView.custom_views.where('instance_id = ?', params[:instance_id])
  end

  def new
    @instance_view = InstanceView.new({locale: PlatformContext.current.instance.primary_locale,
                                       handler: 'haml',
                                       view_type: InstanceView::VIEW_VIEW,
                                       format: 'html',
                                       partial: false })
  end

  def edit
  end

  def create
    @instance_view = InstanceView.new(instance_view_params)
    @instance_view.instance = @instance
    @instance_view.view_type = InstanceView::VIEW_VIEW
    if @instance_view.save
      flash[:success] = 'InstanceView created.'
      redirect_to action: "index"
    else
      flash[:error] = @instance_view.errors.full_messages.to_sentence
      render action: 'new'
    end
  end

  def update
    if @instance_view.update_attributes(instance_view_params)
      flash[:success] = 'InstanceView was successfully updated.'
      redirect_to action: "index"
    else
      flash[:error] = @instance_view.errors.full_messages.to_sentence
      render action: 'edit'
    end
  end

  def destroy
    @instance_view.destroy
    flash[:success] = 'InstanceView was deleted.'
    redirect_to action: "index"
  end

  private

  def set_instance
    @instance = Instance.find(params[:instance_id])
  end

  def set_instance_view
    @instance_view = InstanceView.find(params[:id])
  end

  def instance_view_params
    params.require(:instance_view).permit(secured_params.instance_view)
  end
end
