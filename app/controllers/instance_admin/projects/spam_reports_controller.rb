require 'will_paginate/array'

class InstanceAdmin::Projects::SpamReportsController < InstanceAdmin::Projects::BaseController
  before_filter :find_spammable, only: [ :show, :ignore, :destroy ]

  def index
    @spam_reports = get_spam_reports
  end

  def show
    if @spamable.is_a?(Comment)
      @partial_name = "comments/activity_feed_comment"
      @locals = { comment: @spamable, hide_comment_options: true }
    else
      @partial_name = "shared/activity_status"
      @locals = { event: @spamable }
    end

    render :show, layout: false
  end

  def ignore
    @spamable.spam_ignored = true
    @spamable.save!

    respond_to do |format|
      format.js { render :destroy }
    end
  end

  def destroy
    @spamable.destroy
    respond_to do |format|
      format.js
    end
  end

  private
    def find_spammable
      @spam_report = SpamReport.find(params[:id])
      @spamable = @spam_report.spamable
    end

    def get_spam_reports
      today = Date.current.in_time_zone

      @spam_reports =
        case params[:date]
          when "today"
            SpamReport.between_interval(today - 1.day, today)
          when "yesterday"
            SpamReport.between_interval(today - 2.day, today - 1.day)
          when "week_ago"
            SpamReport.between_interval(today - 1.week, today)
          when "month_ago"
            SpamReport.between_interval(today - 1.month, today)
          when "3_months_ago"
            SpamReport.between_interval(today - 3.month, today)
          else
            SpamReport.all
        end

      @spam_reports.grouped_by_spammable.to_a.paginate(page: params[:page])
    end
end
