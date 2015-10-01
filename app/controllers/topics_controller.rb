class TopicsController < ApplicationController
  def show
    @topic = Topic.find(params[:id])
    @feed = ActivityFeedService.new(@topic)
    @followers = @topic.feed_followers(params)
  end
end
