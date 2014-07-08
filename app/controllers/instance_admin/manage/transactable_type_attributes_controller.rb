class InstanceAdmin::Manage::TransactableTypeAttributesController < InstanceAdmin::Manage::BaseController
  before_filter :find_transactable_type
  before_filter :normalize_complex_params, only: [:create, :update]

  def index
    @transactable_type_attributes = @transactable_type.transactable_type_attributes.listable
  end

  def new
    unless @transactable_type_attribute = @transactable_type.transactable_type_attributes.build
      flash[:error] = t 'flash_messages.instance_admin.manage.transactable_type_attributes.invalid'
      redirect_to action: :index
    end
  end

  def edit
    @transactable_type_attribute = @transactable_type.transactable_type_attributes.listable.find(params[:id])
  end

  def create
    @transactable_type_attribute = @transactable_type.transactable_type_attributes.build(params[:transactable_type_attribute])
    if @transactable_type_attribute.save
      flash[:success] = t 'flash_messages.instance_admin.manage.transactable_type_attributes.created'
      redirect_to action: :index
    else
      flash[:error] = @transactable_type_attribute.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @transactable_type_attribute = @transactable_type.transactable_type_attributes.listable.find(params[:id])
    if @transactable_type_attribute.update_attributes(params[:transactable_type_attribute])
      flash[:success] = t 'flash_messages.instance_admin.manage.transactable_type_attributes.updated'
      redirect_to action: :index
    else
      flash[:error] = @transactable_type_attribute.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @transactable_type_attribute = @transactable_type.transactable_type_attributes.listable.find(params[:id])
    @transactable_type_attribute.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.transactable_type_attributes.deleted'
    redirect_to action: :index
  end

  private

  def find_transactable_type
    @transactable_type = PlatformContext.current.instance.transactable_types.first
  end

  def normalize_complex_params
    if params[:transactable_type_attribute]
      params[:transactable_type_attribute][:valid_values] = normalize_valid_values
      params[:transactable_type_attribute][:input_html_options] = normalize_input_html_options
      params[:transactable_type_attribute][:wrapper_html_options] = normalize_wrapper_html_options
    end
  end
  def normalize_valid_values
    params[:transactable_type_attribute][:valid_values].split(',').map(&:strip)
  end

  def normalize_input_html_options
    transform_hash_string_to_hash(params[:transactable_type_attribute][:input_html_options])
  end

  def normalize_wrapper_html_options
    transform_hash_string_to_hash(params[:transactable_type_attribute][:wrapper_html_options])
  end

  def transform_hash_string_to_hash(hash_string)
    hash_string.split(',').inject({}) do |hash, key_value_string|
      key_value_arr = key_value_string.split('=>')
      hash[key_value_arr[0].strip] = key_value_arr[1].strip
      hash
    end
  end
end
