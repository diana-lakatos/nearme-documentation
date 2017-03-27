class InstanceAdmin::Manage::CategoriesController < InstanceAdmin::Manage::BaseController
  def index
    @categories = Category.roots
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      flash[:success] = t 'flash_messages.instance_admin.manage.category.created'

      respond_to do |format|
        format.html { redirect_to edit_instance_admin_manage_category_path(@category) }
        format.js { render json: @category.to_json }
      end
    else
      @new_category = Category.new
      @categories = Category.roots

      flash[:error] = @category.errors.full_messages.to_sentence
      render action: :index
    end
  end

  def jstree
    if params[:root]
      @categories = Category.roots.where(id: params[:id]).order(:lft)
    else
      @category = Category.find(params[:id])
      @categories = @category.children
    end
    render json: {} if @categories.empty?
  end

  def edit
    append_to_breadcrumbs(t('instance_admin.edit'))
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    @category.attributes = category_params
    rename_message =  t 'flash_messages.instance_admin.manage.category.renamed' if @category.name_changed? && @category.root?
    if @category.save
      respond_to do |format|
        format.html do
          flash[:error] = rename_message if rename_message.present?
          flash[:success] = t 'flash_messages.instance_admin.manage.category.updated'
          redirect_to edit_instance_admin_manage_category_path(@category)
        end
        format.js { render json: { message: rename_message }.to_json }
      end
    else
      flash[:error] = @category.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.category.deleted'
    if request.xhr?
      render json: { success: true }
    else
      redirect_to instance_admin_manage_categories_path
    end
  end

  private

  def category_params
    params.require(:category).permit(secured_params.category)
  end
end
