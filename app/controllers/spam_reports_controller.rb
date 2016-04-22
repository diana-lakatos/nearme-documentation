class SpamReportsController < ApplicationController

  before_filter :find_spamable
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

  private

  def find_spamable
    params.each do |name, value|
      if name =~ /(.+)_id$/ && ["comment_id", "activity_feed_event_id"].include?(name)
        @spamable = $1.classify.constantize.find(value)
      end
    end
    nil
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
