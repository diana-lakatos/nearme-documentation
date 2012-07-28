require "social"

class V1::SocialProviderController < V1::BaseController
  before_filter :require_authentication
  before_filter :validate_update_params!, only: :update

  def show
    render json: social_network_hash
  end

  def update
    uid, info = provider.get_user_info(token, secret)

    raise DNM::InvalidJSONData, "token", "Invalid Credentials" if uid.blank?

    # Create or update the authorization for this user and provider
    current_user.authentications.find_or_create_by_provider(provider_name).tap do |a|
      a.uid    = uid
      a.info   = info
      a.token  = token
      a.secret = secret
    end.save!

    render json: social_network_hash
  end

  def destroy
    auth = current_user.authentications.find_by_provider(provider_name)
    auth.destroy if auth.present?

    render json: social_network_hash
  end


  private

  def provider_name
    params[:provider]
  end

  def provider
    @provider ||= ::Social.provider(provider_name)
  end

  def token
    json_params["token"]
  end

  def secret
    json_params["secret"]
  end

  def validate_update_params!
    raise DNM::MissingJSONData, "token"  if token.blank?
    raise DNM::MissingJSONData, "secret" if secret.blank? && provider.meta[:auth] == "OAuth 1.0a"
  end

  def social_network_hash
    { provider_name => provider.meta_for_user(current_user) }
  end

end
