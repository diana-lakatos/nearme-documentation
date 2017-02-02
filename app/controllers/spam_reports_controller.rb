# frozen_string_literal: true
class SpamReportsController < ApplicationController
  before_action :find_spamable
  before_action :authenticate_user!
  before_action :partial_name

  def create
    @spam_report = @spamable.spam_reports.create!(user: current_user, ip_address: request.remote_ip)
    render :reload_spamable
  end

  def destroy
    @spam_report = @spamable.spam_reports.find(params[:id])
    @spam_report.destroy
    render :reload_spamable
  end

  def cancel
    if @spam_report = current_user.spam_reports.where(spamable: @spamable).first
      @spam_report.destroy
      render :reload_spamable
    else
      render nothing: true
    end
  end

  def index
    render json: feed_data
  end

  private

  def find_spamable
    params.each do |name, value|
      if name =~ /(.+)_id$/ && %w(comment_id activity_feed_event_id).include?(name)
        @spamable = Regexp.last_match(1).classify.constantize.find(value)
      end
    end
    nil
  end

  def feed_data
    return {} unless current_user
    {
      current_user_id: current_user.id,
      comments_spam_reports: current_user.spam_reports.where(spamable_type: 'Comment').pluck(:spamable_id),
      events_spam_reports: current_user.spam_reports.where(spamable_type: 'ActivityFeedEvent').pluck(:spamable_id)
    }
  end

  def partial_name
    @partial_name = if params['comment_id'] && params['activity_feed_event_id']
                      'comments/activity_feed_comment'
                    elsif params['activity_feed_event_id']
                      'shared/activity_status'
                    else
                      'comments/comment'
                    end
  end
end
