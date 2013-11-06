class Locations::SocialShareController < ApplicationController 
  before_filter :find_location

  def new
    event_tracker.mailer_social_share(@location, {provider: params[:provider]}) if params[:track_email_event] && params[:provider]

    redirect_to social_share_redirection_url
  end

  protected

  def find_location
    @location = Location.find(params[:location_id])
  end

  def social_share_redirection_url
    case params[:provider].to_s
    when 'facebook'
      "https://www.facebook.com/sharer/sharer.php?u=#{location_url(@location)}"
    when 'twitter'
      tweet_body = "Need a place to work? Check out our space on @DesksNearMe: #{location_url(@location)}"
      "https://twitter.com/intent/tweet?text=#{URI::escape(tweet_body)}"
    when 'linkedin'
      "http://www.linkedin.com/shareArticle?mini=true&url=#{location_url(@location)}&title=#{URI::escape(@location.name )}&summary=#{URI::escape(@location.description)}&source=DesksNear.Me"
    else
      :back
    end
  end
end
