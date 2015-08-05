class InstanceAdmin::CategoriesController < InstanceAdmin::BaseController

  before_filter :find_categorizable

  def index
    @categories = @categorizable.categories.roots.order(:position)
    @category = Category.new categorizable: @categorizable
  end

  def create
    @category = @categorizable.categories.build(category_params)

    if @category.save
      flash[:success] = t 'flash_messages.instance_admin.manage.category.created'

      respond_to do |format|
        format.html { redirect_to( redirect_path) }
        format.js { render json: @category.to_json }
      end
    else
      @new_category = Category.new categorizable: @categorizable
      @categories = @categorizable.categories.roots.order(:position)

      flash[:error] = @category.errors.full_messages.to_sentence
      render action: :index
    end
  end

  def jstree
    if params[:root]
      @categories = @categorizable.categories.roots.where(id: params[:id]).order(:position)
    else
      @category = @categorizable.categories.find(params[:id])
      @categories = @category.children.order(:position)
    end
  end

  def edit
    append_to_breadcrumbs(t('instance_admin.edit'))
    @category = @categorizable.categories.find(params[:id])
  end

  def update
    @category = @categorizable.categories.find(params[:id])
    @category.attributes = category_params
    rename_message =  t 'flash_messages.instance_admin.manage.category.renamed' if @category.name_changed? && @category.root?
    if @category.save
      respond_to do |format|
        format.html do
          flash[:error] = rename_message if rename_message.present?
          flash[:success] = t 'flash_messages.instance_admin.manage.category.updated'
          redirect_to( redirect_path)
        end
        format.js { render json: {message: rename_message}.to_json }
      end
    else
      flash[:error] = @category.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  def destroy
    @category = @categorizable.categories.find(params[:id])
    @category.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.category.deleted'
    redirect_to redirect_path.split(/\/\d*\/edit/)[0]
  end

  private

  def redirect_path
    @redirect_path ||= url_for(['instance_admin', @controller_scope, @categorizable, @category]) + '/edit'
  end

  def category_params
    params.require(:category).permit(secured_params.category)
  end
end
