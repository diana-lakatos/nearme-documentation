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

  def tree_new_ui
    @selected_categories = Category.where(id: params[:category_ids])
    @category = Category.find(params[:id])
    @categories = @category.children.order(:position)

    render json: build_children_categories(@category)
  end

  private

    def build_children_categories(category)
      category.children.order(:position).map { |child_category| build_category(child_category) }
    end

    def build_category(category)
      {
        id: category.id,
        text: category.translated_name,
        state: {
          opened: category.children.present? && @selected_categories.include?(category),
          checked: @selected_categories.include?(category)
        },
        children: build_children_categories(category)
      }
    end
end
