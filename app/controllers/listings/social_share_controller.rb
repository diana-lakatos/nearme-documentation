class Listings::SocialShareController < ApplicationController
  before_filter :find_listing

  def new
    event_tracker.shared_location_via_social_media(@location, provider: params[:provider], source: 'email') if params[:track_email_event] && params[:provider]

    redirect_to social_share_redirection_url
  end

  protected

  def find_listing
    @listing = Transactable.find(params[:listing_id])
  end

  def social_share_redirection_url
    case params[:provider].to_s
    when 'facebook'
      "https://www.facebook.com/sharer/sharer.php?u=#{@listing.decorate.show_url}"
    when 'twitter'
      tweet_body = "#{t('location.social_share.twitter', instance_name: @listing.instance.name)}: #{@listing.decorate.show_url}"
      "https://twitter.com/intent/tweet?text=#{URI.escape(tweet_body)}"
    when 'linkedin'
      "http://www.linkedin.com/shareArticle?mini=true&url=#{@listing.decorate.show_url}&title=#{URI.escape(@listing.name.to_s)}&summary=#{URI.escape(@listing.description.to_s)}&source=#{URI.escape(@listing.instance.name)}"
    else
      @listing.decorate.show_path
    end
  end
end
