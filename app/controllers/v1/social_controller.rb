class V1::SocialController < V1::BaseController
  before_filter :require_authentication

  def show
    render json: social_network_hash(current_user)
  end

  private

  def social_network_hash(_user)
    { facebook: ::Authentication.provider('facebook').new(user: current_user).meta_for_user,
      twitter: ::Authentication.provider('facebook').new(user: current_user).meta_for_user,
      linkedin: ::Authentication.provider('facebook').new(user: current_user).meta_for_user }
  end
end
