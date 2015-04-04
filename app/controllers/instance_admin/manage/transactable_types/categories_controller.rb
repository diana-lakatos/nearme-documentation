class InstanceAdmin::Manage::TransactableTypes::CategoriesController < InstanceAdmin::BaseController

  before_filter :find_categorable

  def index
    @categories = @categorable.categories.order(:position)
    @category = @categorable.categories.first 
    @new_category = Category.new categorable: @categorable
  end

  def new
    @form_type = params[:form_type]
    @category = @categorable.categories.build(:form_type => @form_type)
  end

  def create
    @category = @categorable.categories.build(category_params)

    if @category.save
      flash[:success] = t 'flash_messages.instance_admin.manage.category.created'
      redirect_to redirect_path
    else
      flash[:error] = @category.errors.full_messages.to_sentence
      render action: :new
    end
  end

  # def show
  #   @category = @categorable.categories.find(params[:id])
  #   @categories = @category.children
  # end

  def jstree
    if params[:root]
      @categories = @categorable.categories.roots.order(:position)
    else
      @category = @categorable.categories.find(params[:id])
      @categories = @category.children.order(:position)
    end
  end

  # def edit
  #   @category = @categorable.categories.find(params[:id])
  # end

  def update
    @category = @categorable.categories.find(params[:id])
    if @category.update_attributes(category_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.category.updated'
      redirect_to redirect_path
    else
      # This will not  happen unless the user plays with the console and is mainly done to make
      # the view renderable so tests can pass
      @category.form_type = FormComponent::SPACE_WIZARD if @category.form_type.blank?

      flash[:error] = @category.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @category = @categorable.categories.find(params[:id])
    @category.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.category.deleted'
    redirect_to redirect_path
  end

  private

  def category_params
    params.require(:category).permit(secured_params.category)
  end

  def find_categorable
    @categorable = TransactableType.find(params[:transactable_type_id])
  end

  def redirect_path
    instance_admin_manage_transactable_type_categories_path(@categorable, @category)
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end
end
