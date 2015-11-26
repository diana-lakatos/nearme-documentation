class InstanceAdmin::Manage::ServiceTypesController < InstanceAdmin::Manage::BaseController

  before_filter :find_service_type, except: [:index, :new, :create]
  before_filter :set_theme, except: [:change_state]
  before_filter :set_breadcrumbs

  def index
    @service_types = ServiceType.all
  end

  def new
    @service_type = ServiceType.new
  end

  def create
    @service_type = ServiceType.new(service_type_params.merge(
      action_free_booking: true,
      action_hourly_booking: true,
      action_daily_booking: true,
      action_weekly_booking: true,
      action_monthly_booking: true,
      availability_options: { "defer_availability_rules" => true, "confirm_reservations" => { "default_value" => true, "public" => true } },
      buyable: false
    ))
    if @service_type.save
      at = @service_type.availability_templates.build(name: "Working Week", description: "Mon - Fri, 9:00 AM - 5:00 PM")
      (1..5).each do |i|
        at.availability_rules.build(day: i, open_hour: 9, open_minute: 0,close_hour: 17, close_minute: 0)
      end
      at.save!
      Utils::FormComponentsCreator.new(@service_type).create!
      @service_type.create_rating_systems
      flash[:success] = t 'flash_messages.instance_admin.manage.service_types.created'
      redirect_to instance_admin_manage_service_types_path
    else
      flash[:error] = @service_type.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    if @service_type.update_attributes(service_type_params)
      @service_type.schedule.try(:create_schedule_from_schedule_rules) if PlatformContext.current.instance.priority_view_path == 'new_ui'
      flash[:success] = t 'flash_messages.instance_admin.manage.service_types.updated'
      redirect_to instance_admin_manage_service_types_path
    else
      flash[:error] = @service_type.errors.full_messages.to_sentence
      render action: params[:action_name]
    end
  end

  def destroy
    @service_type.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.service_types.deleted'
    redirect_to instance_admin_manage_service_types_path
  end

  def change_state
    @service_type.update(service_type_state_params)
    render nothing: true, status: 200
  end

  def search_settings
  end

  private

  def set_breadcrumbs
    @breadcrumbs_title = t('instance_admin.manage.service_types.service_types')
  end

  def set_theme
    @theme_name = 'orders-theme'
  end

  def service_type_params
    params.require(:service_type).permit(secured_params.transactable_type).tap do |whitelisted|
      whitelisted[:custom_csv_fields] = params[:service_type][:custom_csv_fields].map { |el| el = el.split('=>'); { el[0] => el[1] } } if params[:service_type][:custom_csv_fields]
    end
  end

  def find_service_type
    @service_type = TransactableType.find(params[:id])
  end

  def service_type_state_params
    params.require(:service_type).permit(:enable_reviews, :show_reviews_if_both_completed)
  end

end

