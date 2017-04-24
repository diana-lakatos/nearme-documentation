class Dashboard::WishListItemsController < Dashboard::BaseController
  before_action :check_wish_lists_enabled

  def index
    @items = wish_list.items.by_date.decorate
  end

  def destroy
    item.destroy
    redirect_to dashboard_wish_list_items_path, notice: t('flash_messages.wish_list_items.item_deleted')
  end

  def clear
    wish_list.items.destroy_all
    redirect_to dashboard_wish_list_items_path, notice: t('flash_messages.wish_list_items.all_items_deleted')
  end

  private

  def check_wish_lists_enabled
    redirect_to(dashboard_path, notice: t('wish_lists.notices.wish_lists_disabled')) unless platform_context.instance.wish_lists_enabled?
  end

  def wish_list
    @wish_list ||= current_user.default_wish_list
  end

  def item
    wish_list.items.find params[:id]
  end
end
