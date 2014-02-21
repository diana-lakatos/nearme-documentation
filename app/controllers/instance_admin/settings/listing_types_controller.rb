class InstanceAdmin::Settings::ListingTypesController < InstanceAdmin::Settings::BaseController

  def create
    @listing_type = ListingType.new(params[:listing_type])
    if @listing_type.save
      flash[:success] = t('flash_messages.instance_admin.settings.listing_type_added')
      redirect_to instance_admin_settings_listings_path
    else
      flash[:error] = @listing_type.errors.full_messages.to_sentence
      redirect_to instance_admin_settings_listings_path
    end
  end

  def destroy_modal
    @listing_type = ListingType.find(params[:id])

    if @listing_type.listings.count > 0
      @replacement_types = ListingType.all - [@listing_type]
      render :destroy_and_replace_modal, :layout => false
    else
      render :destroy_modal, :layout => false
    end
  end

  def destroy
    @listing_type = ListingType.find(params[:id])

    if @listing_type.listings.count > 0
      @replacement_type = ListingType.find(params[:replacement_type_id])
      @listing_type.listings.update_all(listing_type_id: @replacement_type.id)
    end

    @listing_type.destroy
    flash[:success] = t('flash_messages.instance_admin.settings.listing_type_deleted')
    redirect_to instance_admin_settings_listings_path
  end
end
