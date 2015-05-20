class Dashboard::Api::CategoriesController < Dashboard::Api::BaseController

  def show
    category = Category.find(params[:id])
    categories = category.descendants.where(deleted_at: nil).select(:id, :name, :lft, :rgt).order(:permalink)
    process_collection(categories, :pretty_name)
  end

  def tree
    @selected_categories = Category.where(id: params[:category_ids])
    @category = Category.find(params[:id])
    @categories = @category.children.order(:position)
  end

end
