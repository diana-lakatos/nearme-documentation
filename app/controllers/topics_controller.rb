class TopicsController < ApplicationController
  def show
    @topic = Topic.find(params[:id])
    @feed = ActivityFeedService.new(@topic, current_user: current_user)
    @followers = @topic.feed_followers.paginate(paginate_params)
    @all_transactables = @topic.transactables.active.paginate(paginate_params)
    respond_to :html
  end

  def paginate_params
    {
      page: 1,
      per_page: ActivityFeedService::Helpers::FOLLOWED_PER_PAGE
    }
  end
end
