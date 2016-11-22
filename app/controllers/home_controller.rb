# frozen_string_literal: true
class HomeController < ApplicationController
  def index
    @transactable_types = current_instance.transactable_types.searchable
    @transactable_types += current_instance.instance_profile_types.searchable
    @transactable_types.sort_by!(&:position)
    @transactable_type = @transactable_types.first

    if current_instance.is_community?
      order = ['Networking', 'Dual Screen', 'Big Data', 'Open Source', 'Android', 'Real Sense']

      @hide_intro_video = !!cookies['hide_intro_video']

      if current_user.nil?
        @projects = Transactable.active.featured.take(3)
        @users = User.includes(:current_address).featured.take(8)
        @topics = Topic.featured.take(6).to_a.sort { |a, b| order.index(b.name).to_i <=> order.index(a.name).to_i }
      else
        @topics = Topic.featured.where.not(id: current_user.feed_followed_topics).to_a.sort { |a, b| order.index(b.name).to_i <=> order.index(a.name).to_i }

        @feed = ActivityFeedService.new(current_user.try(:model))

        @projects = Transactable.active.featured.where.not(id: current_user.feed_followed_transactables).take(3)
        @users = User.featured.includes(:current_address).where.not(id: current_user.feed_followed_users).take(8)
        render(:tutorial) && return if current_user.should_render_tutorial?
      end
    end
    respond_to :html
  end
end
