class InstanceAdmin::Settings::LocationTypesController < InstanceAdmin::Settings::BaseController

  def create
    @location_type = LocationType.new(params[:location_type])
    @location_type.instance = platform_context.instance
    if @location_type.save
      flash[:success] = t('flash_messages.instance_admin.settings.location_type_added')
      redirect_to instance_admin_settings_locations_path
    else
      flash[:error] = @location_type.errors.full_messages.to_sentence
      redirect_to instance_admin_settings_locations_path
    end
  end

  def destroy_modal
    @location_type = platform_context.instance.location_types.find(params[:id])

    if @location_type.locations.count > 0
      @replacement_types = platform_context.instance.location_types - [@location_type]
      render :destroy_and_replace_modal, :layout => false
    else
      render :destroy_modal, :layout => false
    end
  end

  def destroy
    @location_type = platform_context.instance.location_types.find(params[:id])

    if @location_type.locations.count > 0
      @replacement_type = platform_context.instance.location_types.find(params[:replacement_type_id])
      @location_type.locations.update_all(location_type_id: @replacement_type.id)
    end

    @location_type.destroy
    flash[:success] = t('flash_messages.instance_admin.settings.location_type_deleted')
    redirect_to instance_admin_settings_locations_path
  end
end
