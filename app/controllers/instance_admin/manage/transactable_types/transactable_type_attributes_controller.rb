class InstanceAdmin::Manage::TransactableTypes::TransactableTypeAttributesController < InstanceAdmin::Manage::BaseController

  before_filter :find_transactable_type
  before_filter :normalize_valid_values, only: [:create, :update]

  def index
    @transactable_type_attributes = @transactable_type.transactable_type_attributes.listable
  end

  def new
    unless @transactable_type_attribute = @transactable_type.transactable_type_attributes.build
      flash[:error] = t 'flash_messages.instance_admin.manage.transactable_type_attributes.invalid'
      redirect_to instance_admin_manage_transactable_type_path(@transactable_type)
    end
  end

  def edit
    @transactable_type_attribute = @transactable_type.transactable_type_attributes.listable.find(params[:id])
  end

  def create
    @transactable_type_attribute = @transactable_type.transactable_type_attributes.build(transactable_type_attributes_params)
    if @transactable_type_attribute.save
      flash[:success] = t 'flash_messages.instance_admin.manage.transactable_type_attributes.created'
      redirect_to instance_admin_manage_transactable_type_path(@transactable_type)
    else
      flash[:error] = @transactable_type_attribute.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @transactable_type_attribute = @transactable_type.transactable_type_attributes.listable.find(params[:id])
    if @transactable_type_attribute.update_attributes(transactable_type_attributes_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.transactable_type_attributes.updated'
      redirect_to instance_admin_manage_transactable_type_path(@transactable_type)
    else
      flash[:error] = @transactable_type_attribute.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @transactable_type_attribute = @transactable_type.transactable_type_attributes.listable.find(params[:id])
    @transactable_type_attribute.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.transactable_type_attributes.deleted'
    redirect_to instance_admin_manage_transactable_type_path(@transactable_type)
  end

  private

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:transactable_type_id])
  end

  def normalize_valid_values
      params[:transactable_type_attribute][:valid_values] = params[:transactable_type_attribute][:valid_values].split(',').map(&:strip) if params[:transactable_type_attribute]
  end

  def transactable_type_attributes_params
    params.require(:transactable_type_attribute).permit(secured_params.transactable_type_attribute)
  end

  def permitting_controller_class
    'manage'
  end
end
