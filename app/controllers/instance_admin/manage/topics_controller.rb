class InstanceAdmin::Manage::TopicsController < InstanceAdmin::Manage::BaseController
  def edit
    @topic = Topic.find(params[:id])
    render layout: false
  end

  def update
    @topic = Topic.find(params[:id])
    @topic.update_columns(topic_params)
    render layout: false
  end

  private

  def topic_params
    params.require(:topic).permit(secured_params.topic)
  end
end
