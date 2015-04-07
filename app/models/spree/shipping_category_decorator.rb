Spree::ShippingCategory.class_eval do
  include Spree::Scoper
  belongs_to :country

  scope :system_profiles , -> {
    where(is_system_profile: true)
  }

  scope :enabled_system_profiles , -> {
    where(is_system_profile: true, is_system_category_enabled: true)
  }

  scope :not_system_profiles, -> {
    where(is_system_profile: false)
  }

  def self.csv_fields
    {name: 'Shipping Category Name'}
  end
end
