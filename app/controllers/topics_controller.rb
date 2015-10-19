class TopicsController < ApplicationController

  def show
    @topic = Topic.find(params[:id])
    @feed = ActivityFeedService.new(@topic)
    @followers = @topic.feed_followers.paginate(paginate_params)
    @all_projects = @topic.projects.enabled.paginate(paginate_params)
  end

  def paginate_params
    {
      page: 1,
      per_page: ActivityFeedService::Helpers::FOLLOWED_PER_PAGE
    }
  end

end
