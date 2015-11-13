namespace :fix do
  desc "Fix buy_sell"
  task :buy_sell_count_on_hand => [:environment] do
    Instance.find_each do |i|
      i.set_context!
      if i.product_types.count.zero?
        puts "Skipping #{i.name}(id=#{i.id})"
        next
      else
        puts "Processing #{i.name}(id=#{i.id})"
      end
      Spree::Variant.find_each do |v|
        if(stock_items = v.stock_items.where('count_on_hand > 0')).size > 1
          puts "\tVariant #{v.id} has #{stock_items.size} stock items with count_on_hand > 0"
          stock_items.first(stock_items.size-1).each do |st|
            puts "\t\tUpdating stock item #{st.id} to change count from #{st.count_on_hand} to 0"
            st.update_attribute(:count_on_hand, 0)
          end
        end
      end
    end
  end

  task :cleanup_deleted_products => [:environment] do
    Instance.find(X).set_context!
    Spree::StockLocation.where(company_id: nil).destroy_all
    Spree::StockItem.with_deleted.each { |si| (si.stock_location.nil? || si.variant.nil? || si.variant.product.nil?) ? si.delete! : si }
    Spree::Product.only_deleted.delete_all
    Spree::Variant.only_deleted.delete_all
    Spree::StockItem.only_deleted.delete_all
  end

  task transactable_types_availability_options: :environment do
    Instance.find_each do |instance|
      instance.set_context!
      TransactableType.all.reject(&:valid?).each do |tt|
        tt.update!(availability_options: {
          "defer_availability_rules" => true,
          "confirm_reservations" => {
            "default_value" => true,
            "public" => true
          }
        })
      end
    end
  end

end

