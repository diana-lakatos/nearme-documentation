class Dashboard::Api::CategoriesController < Dashboard::Api::BaseController

  def show
    category = Category.find(params[:id])
    categories = category.descendants.select(:id, :name, :lft, :rgt).order(:permalink)
    process_collection(categories, :pretty_name)
  end

end
