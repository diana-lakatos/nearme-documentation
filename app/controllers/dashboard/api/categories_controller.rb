# frozen_string_literal: true
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
    @categories = @category.children

    render json: build_children_categories(@category)
  end

  private

  def build_children_categories(category)
    # TODO: note this link https://github.com/collectiveidea/awesome_nested_set/wiki/Awesome-nested-set-cheat-sheet
    # we probably want to use each_with_level or something like this
    # for now quick performance improvement for leafs.
    return [] if category.leaf?
    category.children.map { |child_category| build_category(child_category) }
  end

  def build_category(category)
    {
      id: category.id,
      text: category.translated_name,
      state: {
        opened: !category.leaf? && @selected_categories.include?(category),
        checked: @selected_categories.include?(category)
      },
      children: build_children_categories(category)
    }
  end
end
