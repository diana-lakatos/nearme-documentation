class Manage::BuySell::PrototypesController < Manage::BuySell::BaseController
  before_filter :find_prototype, only: [:edit, :update, :destroy]
  before_filter :set_form_objects, only: [:edit, :update, :new, :create]

  def index
    @prototypes = @company.prototypes.paginate(page: params[:page], per_page: 20)
  end

  def new
    @prototype = @company.prototypes.new()
  end

  def create
    @prototype = @company.prototypes.new(prototype_params)
    if @prototype.save
      redirect_to location_after_save, notice: t('flash_messages.manage.prototype.created')
    else
      flash[:error] = t('flash_messages.manage.prototype.error_create')
      render :new
    end
  end

  def edit
  end

  def update
    if @prototype.update_attributes(prototype_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.prototype.updated')
    else
      flash[:error] = t('flash_messages.manage.prototype.error_update')
      render :edit
    end
  end

  def destroy
    @prototype.destroy
    redirect_to location_after_save
   end

  private

  def location_after_save
    manage_buy_sell_prototypes_path
  end

  def find_prototype
    @prototype = @company.prototypes.find(params[:id])
  end

  def set_form_objects
    @properties = @company.properties
    @option_types = @company.option_types
  end

  def prototype_params
    params.require(:prototype).permit(secured_params.spree_prototype)
  end
end
