class Dashboard::Api::CategoriesController < Dashboard::Api::BaseController
  skip_before_action :authenticate_user!, only: [:show]
  skip_before_action :force_fill_in_wizard_form

  def show
    category = Category.find(params[:id])
    categories = category.descendants.where(deleted_at: nil).select(:id, :name, :lft, :rgt, :position)
    process_collection(categories, :pretty_name, :translated_name)
  end

  def tree
    @selected_categories = Category.where(id: params[:category_ids])
    @category = Category.find(params[:id])
    @categories = @category.children
  end

  def tree_new_ui
    @selected_categories = Category.where(id: params[:category_ids])
    @category = Category.find(params[:id])

    render json: CategoryHashSerializer.new(@category, @selected_categories).to_json[:children]
  end

end
