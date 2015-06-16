desc "Create saved search notification alerts"
task populate_buy_sell_form_components: :environment do
  Instance.find_each do |instance|
    instance.set_context!
    Spree::ProductType.find_each do |pt|
      Utils::FormComponentsCreator.new(pt).create!
      Utils::FormComponentsCreator.new(pt, 'product').create!

    end
  end
end
