# frozen_string_literal: true
module Api
  class V4::WishListItemsController < BaseController
    include WishListItemsHelper

    before_action :check_wish_lists_enabled
    before_action :find_wishlistable, except: [:index]

    def index
      render json: current_user.default_wish_list.items
    end

    def create
      if current_user.default_wish_list.items.find_by(wishlistable: @item)
        render json: ApiSerializer.serialize_errors('already_listed': 'This item is already listed.')
        return
      end

      wish_list_item = current_user.default_wish_list.items.create wishlistable: @item
      render nothing: true, status: 204
    end

    def destroy
      current_user.default_wish_list.items.find_by(wishlistable: @item).try(:destroy)
      render nothing: true, status: 204
    end

    private

    def find_wishlistable
      klass_name = params[:wishlistable_type].presence
      check_permitted_object_type(klass_name)

      @item = klass_name.constantize.find(params[:id])
    end

    def check_wish_lists_enabled
      unless PlatformContext.current.instance.wish_lists_enabled?
        raise WishListItem::Disabled, 'Wish lists are disabled for this marketplace'
      end
    end

    def check_permitted_object_type(klass_name)
      unless WishListItem::PERMITTED_CLASSES.include?(klass_name)
        raise WishListItem::NotPermitted, "Class #{klass_name} is not permitted as wish list item. You have to add it to WishListItem::PERMITTED_CLASSES"
      end
    end
  end
end
