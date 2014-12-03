namespace :spree do
  desc 'Delete all Spree data. For development only'
  task :erase do
    raise 'This task is intended for development environment only' unless Rails.env.development?

    Spree::Zone.delete_all
    Spree::Order.delete_all
    Spree::State.delete_all
    Spree::Product.delete_all
    Spree::TaxRate.delete_all
    Spree::Country.delete_all
    Spree::LineItem.delete_all
    Spree::Taxonomy.delete_all
    Spree::TaxCategory.delete_all
    Spree::StockLocation.delete_all
    Spree::ShippingMethod.delete_all
    Spree::ShippingCategory.delete_all
  end
end

