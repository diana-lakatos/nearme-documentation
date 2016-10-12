class InstanceAdmin::Settings::LocationTypesController < InstanceAdmin::Settings::BaseController
  def create
    @location_type = LocationType.new(location_type_params)
    if @location_type.save
      flash[:success] = t('flash_messages.instance_admin.settings.location_type_added')
      redirect_to instance_admin_settings_locations_path
    else
      flash[:error] = @location_type.errors.full_messages.to_sentence
      redirect_to instance_admin_settings_locations_path
    end
  end

  def update
    if request.xhr?
      @location_type = LocationType.find(params[:id])
      render json: { success: @location_type.update_attributes(location_type_params) }
    else
      fail ActionController::MethodNotAllowed
    end
  end

  def destroy_modal
    @location_type = LocationType.find(params[:id])

    if @location_type.locations.count > 0
      @replacement_types = LocationType.all - [@location_type]
      render :destroy_and_replace_modal, layout: false
    else
      render :destroy_modal, layout: false
    end
  end

  def destroy
    @location_type = LocationType.find(params[:id])

    if @location_type.locations.count > 0
      @replacement_type = LocationType.find(params[:replacement_type_id])
      @location_type.locations.update_all(location_type_id: @replacement_type.id)
    end

    @location_type.destroy
    flash[:success] = t('flash_messages.instance_admin.settings.location_type_deleted')
    redirect_to instance_admin_settings_locations_path
  end

  private

  def location_type_params
    params.require(:location_type).permit(secured_params.location_type)
  end
end
