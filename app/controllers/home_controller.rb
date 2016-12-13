# frozen_string_literal: true
class HomeController < ApplicationController
  skip_before_action :redirect_unverified_user

  def index
    @transactable_types = current_instance.transactable_types.searchable
    @transactable_types += current_instance.instance_profile_types.searchable
    @transactable_types.sort_by!(&:position)
    @transactable_type = @transactable_types.first
    render_for_community

    respond_to :html
  end

  private

  def render_for_community
    return unless current_instance.is_community?
    @hide_intro_video = !!cookies['hide_intro_video']
    if current_user
      order = instance_topics_order
      @topics = Topic.featured.where.not(id: current_user.feed_followed_topics).to_a.sort { |a, b| order.index(b.name).to_i <=> order.index(a.name).to_i }

      @feed = ActivityFeedService.new(current_user.try(:model))

      @projects = Transactable.active.featured.where.not(id: current_user.feed_followed_transactables).take(3)
      @users = User.featured.includes(:current_address).where.not(id: current_user.feed_followed_users).take(8)
      render(:tutorial) && return if current_user.should_render_tutorial?
    end
  end

  def instance_topics_order
    case current_instance.id
    when 5011 # hallmark
      ['Featured Artist', 'Featured Series', 'Ask a Keepsake Artist', '2017 Convention', 'Upcoming Events', 'Tutorials']
    else
      ['Networking', 'Dual Screen', 'Big Data', 'Open Source', 'Android', 'Real Sense']
    end
  end
end
