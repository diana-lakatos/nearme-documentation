class InstanceAdmin::Manage::TransactableTypesController < InstanceAdmin::Manage::BaseController
  before_filter :set_theme, except: [:change_state]
  before_filter :translation_key
  before_filter :set_breadcrumbs
  before_filter :set_cancellation_policy_conditions, only: [:new, :edit, :create, :update]

  def index
  end

  def new
    @transactable_type = resource_class.new
    @transactable_type.try(:initialize_action_types)
  end

  def create
    @transactable_type = resource_class.new(transactable_type_params)
    if @transactable_type.save
      at = @transactable_type.availability_templates.build(name: 'Working Week', description: 'Mon - Fri, 9:00 AM - 5:00 PM')
      (1..5).each do |i|
        at.availability_rules.build(day: i, open_hour: 9, open_minute: 0, close_hour: 17, close_minute: 0)
      end
      at.save!
      Utils::FormComponentsCreator.new(@transactable_type).create!
      @transactable_type.create_rating_systems
      flash[:success] = t "flash_messages.instance_admin.#{controller_scope}.#{translation_key}.created"
      redirect_to [:instance_admin, controller_scope, resource_class]
    else
      flash[:error] = @transactable_type.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def edit
    resource.try(:initialize_action_types)
  end

  def update
    if resource.update_attributes(transactable_type_params)
      flash[:success] = t "flash_messages.instance_admin.#{controller_scope}.#{translation_key}.updated"
      redirect_to [:instance_admin, controller_scope, resource_class]
    else
      flash[:error] = resource.errors.full_messages.to_sentence
      render action: params[:action_name]
    end
  end

  def destroy
    resource.destroy
    flash[:success] = t "flash_messages.instance_admin.#{controller_scope}.#{translation_key}.deleted"
    redirect_to [:instance_admin, controller_scope, resource_class]
  end

  def search_settings
    @breadcrumbs_title = BreadcrumbsList.new(
      { url: polymorphic_url([:instance_admin, @controller_scope, resource_class]), title: t("instance_admin.#{@controller_scope}.#{translation_key}.#{translation_key}") },
      { title: resource.name.titleize },
      title: t('instance_admin.manage.transactable_types.search_settings')
    )
  end

  def change_state
    @transactable_type = TransactableType.find(params[:id])
    @transactable_type.update(transactable_type_params)
    render nothing: true, status: 200
  end

  def show
    redirect_to [:instance_admin, controller_scope, resource_class]
  end

  private

  def collection
    @transactable_types ||= resource_class.all
  end

  def resource
    @transactable_type ||= resource_class.find(params[:id])
  end

  def translation_key
    @translation_key ||= resource_class.name.demodulize.tableize
  end

  def set_breadcrumbs
    @breadcrumbs_title = t("instance_admin.#{controller_scope}.#{translation_key}.#{translation_key}")
  end

  def resource_class
    TransactableType
  end

  def controller_scope
    @controller_scope ||= :manage
  end

  def set_theme
    @theme_name = 'orders-theme'
  end

  def transactable_type_params
    params_key = translation_key.singularize.to_sym
    params.require(params_key).permit(secured_params.transactable_type).tap do |whitelisted|
      whitelisted[:custom_csv_fields] = params[params_key][:custom_csv_fields].map { |el| el = el.split('=>'); { el[0] => el[1] } } if params[params_key][:custom_csv_fields]
    end
  end

  def set_cancellation_policy_conditions
    @cancellation_conditions = CancellationPolicyCondition.all.to_json(:only => [:name, :translated_name, :variables, :query, :id])
  end
end
