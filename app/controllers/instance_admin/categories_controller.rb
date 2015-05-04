class InstanceAdmin::CategoriesController < InstanceAdmin::BaseController

  before_filter :find_categorable

  def index
    @categories = @categorable.categories.roots.order(:position)
    @category = Category.new categorable: @categorable
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
    @category = @categorable.categories.find(params[:id])
    @category.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.category.deleted'
    redirect_to redirect_path.split(/\/\d*\/edit/)[0]
  end

  private

  def redirect_path
    url_for(['instance_admin', @controller_scope, @categorable, @category]) + '/edit'
  end

  def category_params
    params.require(:category).permit(secured_params.category)
  end
end
