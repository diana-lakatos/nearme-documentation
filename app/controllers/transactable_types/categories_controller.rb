class TransactableTypes::CategoriesController < ApplicationController

  before_filter :set_commentable
  before_filter :set_selected_categories

  def index
    @categories = @commentable.categories.roots.where(id: params[:category_id]).order(:position)
    render :jstree
  end

  def show
    @category = @commentable.categories.find(params[:id])
    @categories = @category.children.order(:position)
    render :jstree
  end

  private

  def set_commentable
    if params[:product_type_id]
      @commentable = Spree::ProductType.find(params[:product_type_id])
    else
      @commentable = TransactableType.find(params[:transactable_type_id])
    end
  end

  def set_selected_categories
    @selected_categories = @commentable.categories.where(id: params[:category_ids])
  end
end