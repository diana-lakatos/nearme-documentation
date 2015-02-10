class Dashboard::WishListItemsController < Dashboard::BaseController
  skip_before_filter :redirect_unless_registration_completed
  before_filter :find_default_wish_list
  before_filter :create_default_wish_list
  before_filter :find_item, only: [:destroy]

  def index
    @items = @wish_list.items.by_date
  end

  def destroy
    @item.destroy
    redirect_to dashboard_wish_list_items_path, notice: t('flash_messages.wish_list_items.item_deleted')
  end

  def clear
    @wish_list.items.destroy_all
    redirect_to dashboard_wish_list_items_path, notice: t('flash_messages.wish_list_items.all_items_deleted')
  end

  private

  def find_default_wish_list
    @wish_list = current_user.default_wish_list
  end

  def create_default_wish_list
    @wish_list = current_user.wish_lists.create(name: t('wish_lists.name'), default: true) unless @wish_list
  end

  def find_item
    @item = @wish_list.items.find params[:id]
  end
end
