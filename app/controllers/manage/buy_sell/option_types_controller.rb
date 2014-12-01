class Manage::BuySell::OptionTypesController < Manage::BuySell::BaseController
  before_filter :find_option_type, only: [:edit, :update, :destroy]

  def index
    @option_types = @company.option_types.paginate(page: params[:page], per_page: 20)
  end

  def new
    @option_type = @company.option_types.new()
    build_objects
  end

  def create
    @option_type = @company.option_types.new(option_type_params)
    if @option_type.save
      redirect_to location_after_save, notice: t('flash_messages.manage.option_type.created')
    else
      flash[:error] = t('flash_messages.manage.option_type.error_create')
      render :new
    end
  end

  def edit
  end

  def update
    if @option_type.update_attributes(option_type_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.option_type.updated')
    else
      flash[:error] = t('flash_messages.manage.option_type.error_update')
      render :edit
    end
  end

  def destroy
    @option_type.destroy
    flash[:notice] = t('flash_messages.manage.option_type.deleted')
    redirect_to location_after_save
   end

  private

  def location_after_save
    manage_buy_sell_option_types_path
  end

  def find_option_type
    @option_type = @company.option_types.find(params[:id])
    build_objects
  end

  def build_objects
    @option_type.option_values.build if @option_type.present? && @option_type.option_values.blank?
  end

  def option_type_params
    params.require(:option_type).permit(secured_params.spree_option_type)
  end
end
