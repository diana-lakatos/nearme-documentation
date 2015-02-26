class InstanceAdmin::Manage::TransactableTypesController < InstanceAdmin::Manage::BaseController

  before_filter :set_theme, except: [:change_state]

  def index
    @transactable_types = TransactableType.all
  end

  def new
    @transactable_type = TransactableType.new
  end

  def create
    @transactable_type = TransactableType.new(transactable_type_params.merge(
      action_free_booking: true, 
      action_hourly_booking: true,
      action_daily_booking: true, 
      action_weekly_booking: true, 
      action_monthly_booking: true,
      availability_options: { "defer_availability_rules" => true,"confirm_reservations" => { "default_value" => true, "public" => true } }
    ))
    if @transactable_type.save
      CustomAttributes::CustomAttribute::Creator.new(@transactable_type, bookable_noun: @transactable_type.name).create_listing_attributes!
      at = @transactable_type.availability_templates.build(name: "Working Week", description: "Mon - Fri, 9:00 AM - 5:00 PM")
      (1..5).each do |i|
        at.availability_rules.build(day: i, open_hour: 9, open_minute: 0,close_hour: 17, close_minute: 0)
      end
      at.save!
      Utils::FormComponentsCreator.new(@transactable_type).create!
      Utils::FormComponentsCreator.new(@transactable_type, 'transactable').create!
      flash[:success] = t 'flash_messages.instance_admin.manage.transactable_types.created'
      redirect_to instance_admin_manage_transactable_types_path
    else
      flash[:error] = @transactable_type.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @transactable_type = TransactableType.find(params[:id])
    if @transactable_type.update_attributes(transactable_type_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.transactable_types.updated'
      redirect_to instance_admin_manage_transactable_types_path
    else
      flash[:error] = @transactable_type.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @transactable_type = TransactableType.find(params[:id])
    @transactable_type.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.transactable_types.deleted'
    redirect_to instance_admin_manage_transactable_types_path
  end

  def change_state
    @transactable_type = TransactableType.find(params[:id])
    @transactable_type.update(transactable_type_state_params)
    render nothing: true, status: 200
  end

  private

  def set_theme
    @theme_name = 'orders-theme'
  end

  def transactable_type_params
    params.require(:transactable_type).permit(secured_params.transactable_type).tap do |whitelisted|
      whitelisted[:custom_csv_fields] = params[:transactable_type][:custom_csv_fields].map { |el| el = el.split('=>'); { el[0] => el[1] } } if params[:transactable_type][:custom_csv_fields]
    end

  end

  def transactable_type_state_params
    params.require(:transactable_type).permit(:enable_reviews)
  end

end

