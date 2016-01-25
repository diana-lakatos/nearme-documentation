class InstanceAdmin::Projects::TopicsController < InstanceAdmin::Projects::BaseController

  def index
    @topics = Topic.all
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params)
    if @topic.save
      DataSourceSynchronizeJob.perform(@topic.data_source.id)
      flash[:success] = t 'flash_messages.instance_admin.projects.topics.created'
      redirect_to instance_admin_projects_topics_path
    else
      flash.now[:error] = @topic.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(topic_params)
      DataSourceSynchronizeJob.perform(@topic.data_source.id)
      flash[:success] = t 'flash_messages.instance_admin.projects.topics.updated'
      redirect_to instance_admin_projects_topics_path
    else
      flash.now[:error] = @topic.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy
    flash[:success] = t 'flash_messages.instance_admin.projects.topics.deleted'
    redirect_to instance_admin_projects_topics_path
  end

  private

  def topic_params
    params.require(:topic).permit(secured_params.topic)
  end

end

