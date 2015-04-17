class TransactableTypes::CategoriesController < ApplicationController

  before_filter :set_transactable_type
  before_filter :set_selected_categories

  def index
    @categories = @transactable_type.categories.roots.where(id: params[:category_id]).order(:position)
    render :jstree
  end

  def show
    @category = @transactable_type.categories.find(params[:id])
    @categories = @category.children.order(:position)
    render :jstree
  end

  private

  def set_transactable_type
    @transactable_type = TransactableType.find(params[:transactable_type_id])
  end

  def set_selected_categories
    @selected_categories = @transactable_type.categories.where(id: params[:category_ids])
  end
end