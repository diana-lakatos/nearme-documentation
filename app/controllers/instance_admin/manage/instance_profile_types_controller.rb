class InstanceAdmin::Manage::InstanceProfileTypesController < InstanceAdmin::Manage::BaseController

  before_filter :set_breadcrumbs

  def index
    @instance_profile_types = InstanceProfileType.order(:name)
  end

  def enable
    if (@instance_profile_type = InstanceProfileType.default.first).nil?
       @instance_profile_type = InstanceProfileType.create(name: "User Instance Profile")
      flash[:notice] = 'Custom attributes for user have been enabled'
    else
      flash[:error] = 'Custom attributes for user already enabled'
    end
    redirect_to instance_admin_manage_instance_profile_type_custom_attributes_path(@instance_profile_type)
  end

  def update
    @instance_profile_type = InstanceProfileType.find(params[:id])
    if @instance_profile_type.update_attributes(instance_profile_type_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.service_types.updated'
      redirect_to instance_admin_manage_instance_profile_types_path
    else
      flash[:error] = @instance_profile_type.errors.full_messages.to_sentence
      render action: params[:action_name]
    end
  end

  def destroy
    @instance_profile_type = InstanceProfileType.find(params[:id])
    @instance_profile_type.destroy
    flash[:notice] = 'Custom attributes for user have been disabled'
    redirect_to instance_admin_manage_instance_profile_types_path
  end

  def search_settings
    @instance_profile_type = InstanceProfileType.find(params[:id])
  end

  private

  def set_breadcrumbs
    @breadcrumbs_title = I18n.t('instance_admin.manage.instance_profile_types.manage')
  end

  def instance_profile_type_params
    params.require(:instance_profile_type).permit(secured_params.instance_profile_type)
  end

end
