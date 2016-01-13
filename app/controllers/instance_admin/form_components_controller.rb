class InstanceAdmin::FormComponentsController  < InstanceAdmin::ResourceController

  before_filter :find_form_componentable

  def index
    @form_components = @form_componentable.form_components.rank(:rank).order('form_type')
  end

  def new
    @form_type = params[:form_type]
    @form_component = @form_componentable.form_components.build(:form_type => @form_type)
  end

  def create
    @form_component = @form_componentable.form_components.build(form_component_params)
    if @form_component.save
      flash[:success] = t 'flash_messages.instance_admin.manage.form_component.created'
      redirect_to redirect_path
    else
      # This will not  happen unless the user plays with the console and is mainly done to make
      # the view renderable so tests can pass; can't use ||= because it may be a blank string
      @form_component.form_type = FormComponent::SPACE_WIZARD if @form_component.form_type.blank?

      flash.now[:error] = @form_component.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def edit
    @form_component = @form_componentable.form_components.find(params[:id])
  end

  def update
    @form_component = @form_componentable.form_components.find(params[:id])
    if @form_component.update_attributes(form_component_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.form_component.updated'
      redirect_to redirect_path
    else
      # This will not  happen unless the user plays with the console and is mainly done to make
      # the view renderable so tests can pass
      @form_component.form_type = FormComponent::SPACE_WIZARD if @form_component.form_type.blank?

      flash.now[:error] = @form_component.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @form_component = @form_componentable.form_components.find(params[:id])
    @form_component.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.form_component.deleted'
    redirect_to redirect_path
  end

  def update_rank
    @form_component = @form_componentable.form_components.find(params[:id])
    @form_component.update_attribute(:rank_position, params[:rank_position])
    respond_to do |format|
      format.json { head :ok }
    end

  end

  private

  def find_form_componentable
    raise NotImplementedError
  end

  def permitting_controller_class
    'manage'
  end

  def form_component_params
    params.require(:form_component).permit(secured_params.form_component).tap do |whitelisted|
      whitelisted[:form_fields] = params[:form_component][:form_fields].map { |el| el = el.split('=>'); { el[0].try(:strip) => el[1].try(:strip) } } if params[:form_component][:form_fields]
    end

  end
end
