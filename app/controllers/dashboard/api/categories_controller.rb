class Dashboard::Api::CategoriesController < Dashboard::Api::BaseController

  skip_before_filter :authenticate_user!, only: [:show]

  def show
    category = Category.find(params[:id])
    categories = category.descendants.where(deleted_at: nil).select(:id, :name, :lft, :rgt, :position)
    process_collection(categories, :pretty_name, :translated_name)
  end

  def tree
    @selected_categories = Category.where(id: params[:category_ids])
    @category = Category.find(params[:id])
    @categories = @category.children.order(:position)
  end

end
