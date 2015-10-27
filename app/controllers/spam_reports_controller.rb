class SpamReportsController < ApplicationController

  before_filter :find_spamable
  before_action :authenticate_user!

  def create
    @spamable.spam_reports.create!(user: current_user, ip_address: request.remote_ip)
    render :reload_spamable
  end

  def destroy
    @spam_report = @spamable.spam_reports.find(params[:id])
    @spam_report.destroy
    render :reload_spamable
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
end
