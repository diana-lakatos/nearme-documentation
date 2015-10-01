class ActivityFeedController < ApplicationController
  before_filter :authenticate_user!, :set_object_with_followed_whitelist

  # "Follow/Unfollow" feature section
  #
  # Parameters that should be provided:
  # Mandatory:
  # id              |  The id of the object which should be followed
  # type            |  The type of the object that should be followed

  def follow
    current_user.feed_follow!(@object)
    respond_to do |format|
      format.js { render :follow_and_unfollow }
    end
  end

  def unfollow
    current_user.feed_unfollow!(@object)
    respond_to do |format|
      format.js { render :follow_and_unfollow }
    end
  end


  # "See more" feature section
  #
  # Parameters that should be provided:
  # Mandatory:
  # page            |  The current page we're in
  # id              |  The object which dictates the scope of the query
  # type            |  The type of the resource we should find.
  #
  # Optionals:
  # containter      |  The container to append the new results

  def activity_feed
    @container = params[:container].presence || "#activity"
    @feed = ActivityFeedService.new(@object)

    @partial = "shared/activity_status"
    @as = :event
    @collection = @feed.events(params)
    @hide = !@feed.next_page?

    respond_to do |format|
      format.js { render :see_more }
    end
  end

  def following_people
    @container = params[:container].presence || "#following-people"

    @partial = "shared/person"
    @as = :user
    @collection = @object.feed_following(params).users
    @hide = @collection.count == 0

    respond_to do |format|
      format.js { render :see_more }
    end
  end

  def following_projects
    @container = params[:container].presence || "#following-projects"

    @partial = "shared/project"
    @as = :project
    @collection = @object.feed_following(params).projects
    @hide = @collection.count == 0

    respond_to do |format|
      format.js { render :see_more }
    end
  end

  def following_topics
    @container = params[:container].presence || "#following-topics"

    @partial = "shared/topic"
    @as = :topic
    @collection = @object.feed_following(params).topics
    @hide = @collection.count == 0

    respond_to do |format|
      format.js { render :see_more }
    end
  end

  def followers
    @container = params[:container].presence || "#followers"

    @partial = "shared/person"
    @as = :user
    @collection = @object.feed_followers(params)
    @hide = @collection.count == 0

    respond_to do |format|
      format.js { render :see_more }
    end
  end

  def projects
    @container = params[:container].presence || "#projects"

    per = ActivityFeedService::EVENTS_PER_PAGE
    offset = params[:page].to_i * per - per

    @partial = "shared/project"
    @as = :project
    @collection = @object.try(:projects_collaborated).try(:offset, offset).try(:limit, per) || @object.projects.offset(offset).limit(per)
    @hide = @collection.count == 0

    respond_to do |format|
      format.js { render :see_more }
    end
  end

  private

  def set_object(whitelist)
    @id, @type = params[:id], params[:type].gsub("Decorator", "")
    render json: {}, status: 422 && return if !@id.present? && !@type.present?

    if whitelist.include?(@type)
      @object = @type.constantize.find(@id)
    else
      render json: {}, status: 422 && return
    end
  end

  def set_object_with_followed_whitelist
    set_object(ActivityFeedService::Helpers::FOLLOWED_WHITELIST)
  end
end
