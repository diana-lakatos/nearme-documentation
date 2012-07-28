require "social"

class V1::SocialController < V1::BaseController
  before_filter :require_authentication

  def show
    render json: social_network_hash(current_user)
  end

  private

  def social_network_hash(user)
    { facebook: ::Social.provider("facebook").meta_for_user(user),
      twitter:  ::Social.provider("twitter" ).meta_for_user(user),
      linkedin: ::Social.provider("linkedin").meta_for_user(user) }
  end

end
