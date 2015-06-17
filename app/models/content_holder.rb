class ContentHolder < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  class NotFound < ActiveRecord::RecordNotFound; end

  scope :enabled, -> { where(enabled: true) }
  scope :by_inject_pages, -> (path_group) { where("? = ANY (inject_pages)", path_group) }

  belongs_to :theme
  belongs_to :instance

  after_validation :expire_cache
  after_destroy :expire_cache

  INJECT_PAGES = {
    'listings/reservations#review' => 'checkout',
    'buy_sell_market/checkout#show' => 'checkout',
    'buy_sell_market/cart#index' => 'cart',
    'dashboard/user_reservations#booking_successful' => 'checkout_success',
    'dashboard/orders#success' => 'checkout_success',
    'buy_sell_market/products#show' => 'service/product_page',
    'locations#show' => 'service/product_page',
    'locations/listings#show' => 'service/product_page',
  }


  def expire_cache
    [name, name_was].each do |field|
      Rails.cache.delete("theme.#{theme_id}.content_holders.names.#{field}")
    end
    (inject_pages + inject_pages_was).uniq.each do |page|
      INJECT_PAGES.each_pair do |controller, group|
        Rails.cache.delete("views/theme.#{theme_id}.content_holders.paths.#{controller}") if group == page
      end
    end
  end

  def with_content_for
    if position.present?
      <<-LIQ
        {% content_for #{position} %}
          #{content}
        {% endcontent_for %}
      LIQ
    else
      content
    end
  end

end
