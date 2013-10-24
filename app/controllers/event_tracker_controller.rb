class EventTrackerController < ApplicationController
  AVAILABLE_EVENTS = %w(photo_not_processed_before_submit user_closed_browser_photo_not_processed_before_submit)

  before_filter :authenticate_user!

  layout false

  def create
    event_tracker.public_send(params[:event], current_user, params[:event_options] || {}) if EventTrackerController::AVAILABLE_EVENTS.include?(params[:event]) 

    render nothing: true
  end

end
