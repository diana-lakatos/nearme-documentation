class WishListController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_item

  PERMITTED_CLASSES = %w(Spree::Product Location)

  class NotPermitted < Exception
  end

  def add_item
    if current_user.default_wish_list.items.find_by(wishlistable_id: @item.id)
      redirect_to polymorphic_path(@item), notice: t('wish_lists.notices.already_listed')
      return
    end

    wish_list_item = @item.wish_list_items.create wish_list_id: current_user.default_wish_list.id

    respond_to do |format|
      format.html { redirect_to polymorphic_path(wish_list_item.wishlistable), notice: t('wish_lists.notices.item_added') }
      format.js
    end
  end

  def remove_item
    current_user.default_wish_list.items.find_by(wishlistable_id: @item.id).destroy

    respond_to do |format|
      format.html { redirect_to polymorphic_path(@item), notice: t('wish_lists.notices.item_added') }
      format.js
    end
  end

  private

  def find_item
    klass_name = params[:wishlistable_type]
    unless PERMITTED_CLASSES.include?(klass_name)
      raise NotPermitted, "Class #{klass_name} is not permitted as wish list item. You have to add it to WishListController::PERMITTED_CLASSES"
    end

    @item = klass_name.constantize.find(params[:object_id])
  end
end
