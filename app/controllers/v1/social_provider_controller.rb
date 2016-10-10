class V1::SocialProviderController < V1::BaseController
  before_filter :require_authentication
  before_filter :validate_update_params!, only: :update

  def show
    render json: social_network_hash
  end

  def update
    uid = provider.info.uid
    info = provider.info.hash

    fail DNM::InvalidJSONData, 'token', 'Invalid Credentials' if uid.blank?

    # Create or update the authorization for this user and provider
    auth = Authentication.where(provider: provider_name, uid: uid).first
    fail DNM::Unauthorized if auth && auth.user != current_user

    current_user.authentications.where(provider: provider_name).first_or_create.tap do |a|
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
    @provider ||= ::Authentication.provider(provider_name).new(token: token, secret: secret, user: current_user)
  end

  def token
    json_params['token']
  end

  def secret
    json_params['secret']
  end

  def validate_update_params!
    fail DNM::MissingJSONData, 'token'  if token.blank?
    fail DNM::MissingJSONData, 'secret' if secret.blank? && provider.is_oauth_1?
  end

  def social_network_hash
    provider = Authentication.provider(provider_name).new(user: current_user)
    { provider_name => provider.meta_for_user }
  end
end
