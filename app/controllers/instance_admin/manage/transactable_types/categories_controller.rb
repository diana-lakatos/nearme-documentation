class InstanceAdmin::Manage::TransactableTypes::CategoriesController < InstanceAdmin::BaseController

  before_filter :find_categorable

  def index
    @categories = @categorable.categories.roots.order(:position)
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

      respond_to do |format|
        format.html { redirect_to( redirect_path) }
        format.js { render json: @category.to_json }
      end
    else
      @new_category = Category.new categorable: @categorable
      @categories = @categorable.categories.roots.order(:position)

      flash[:error] = @category.errors.full_messages.to_sentence
      render action: :index
    end
  end

  def jstree
    if params[:root]
      @categories = @categorable.categories.roots.where(id: params[:id]).order(:position)
    else
      @category = @categorable.categories.find(params[:id])
      @categories = @category.children.order(:position)
    end
  end

  def edit
    @category = @categorable.categories.find(params[:id])
  end

  def update
    @category = @categorable.categories.find(params[:id])
    @category.attributes = category_params
    flash[:error] =  t 'flash_messages.instance_admin.manage.category.renamed' if @category.name_changed?

    if @category.save
      flash[:success] = t 'flash_messages.instance_admin.manage.category.updated'
      redirect_to redirect_path
    else
      flash[:error] = @category.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @category = @categorable.categories.find(params[:id])
    @category.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.category.deleted'
    redirect_to instance_admin_manage_transactable_type_categories_path(@categorable)
  end

  private

  def category_params
    params.require(:category).permit(secured_params.category)
  end

  def find_categorable
    @categorable = TransactableType.find(params[:transactable_type_id])
  end

  def redirect_path
    edit_instance_admin_manage_transactable_type_category_path(@categorable, @category)
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end
end
