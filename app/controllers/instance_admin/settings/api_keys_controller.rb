require 'nearme/r53'

class InstanceAdmin::Settings::ApiKeysController < InstanceAdmin::Settings::BaseController
  before_action :find_api_key, only: [:edit, :update, :destroy]

  def index
    @api_keys = ApiKey.all
  end

  def create
    ApiKey.create!
    flash[:success] = t('flash_messages.instance_admin.settings.api_keys.created')
    redirect_to instance_admin_settings_api_keys_path
  end

  def destroy
    @api_key.destroy
    flash[:success] = t('flash_messages.instance_admin.settings.api_keys.deleted')
    redirect_to instance_admin_settings_api_keys_path
  end

  private

  def find_api_key
    @api_key ||= ApiKey.find(params[:id])
  end
end
