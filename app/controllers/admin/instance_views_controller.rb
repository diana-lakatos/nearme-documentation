class Admin::InstanceViewsController < Admin::BaseController
  before_filter :set_instance, :except => [:destroy]
  before_filter :set_instance_view, :only => [:edit, :update, :destroy]

  def index
    @instance_views = InstanceView.where('instance_id = ?',
                                         params[:instance_id])
  end

  def new
    @instance_view = InstanceView.new({locale: 'en',
                                       handler: 'haml',
                                       format: 'html',
                                       partial: false })
  end

  def edit
  end

  def create
    @instance_view = InstanceView.new(params[:instance_view])
    @instance_view.instance = @instance
    if @instance_view.save
      flash[:success] = 'InstanceView created.'
      redirect_to action: "index"
    else
      flash[:error] = @instance_view.errors.full_messages.to_sentence
      render action: 'new'
    end
  end

  def update
    if @instance_view.update_attributes(params[:instance_view])
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
end
