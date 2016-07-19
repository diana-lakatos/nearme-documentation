class ShippingRule < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  has_and_belongs_to_many :countries
  belongs_to :shipping_profile

  monetize :price_cents, with_model_currency: PlatformContext.current.try {|c| c.instance.default_currency }, allow_nil: true

end
