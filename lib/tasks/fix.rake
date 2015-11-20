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

  task fix_missing_country_calling_codes: :environment do
    calling_codes = {
      15 => ['Åland Islands', 358],
      22 => ['Bulgaria', 359],
      26 => ['Saint Barthélemy', 590],
      29 => ['Bolivia, Plurinational State of', 591],
      30 => ['Bonaire, Sint Eustatius and Saba', 599],
      34 => ['Bouvet Island', 47],
      39 => ['Cocos (Keeling) Islands', 61],
      40 => ['Congo, The Democratic Republic of the', 243],
      44 => ["Côte d'Ivoire", 225],
      53 => ['Curaçao', 599],
      55 => ['Cyprus', 357],
      72 => ['Falkland Islands (Malvinas)', 500],
      73 => ['Micronesia, Federated States of', 691],
      90 => ['South Georgia and the South Sandwich Islands', 500],
      96 => ['Heard Island and McDonald Islands', 672],
      108 => ['Iran, Islamic Republic of', 98],
      116 => ['Kyrgyzstan', 996],
      121 => ["Korea, Democratic People's Republic of", 850],
      122 => ["Korea, Republic of", 82],
      126 => ["Lao People's Democratic Republic", 856],
      139 => ["Moldova, Republic of", 373],
      141 => ["Saint Martin (French part)", 590],
      144 => ["Macedonia, Republic of", 389],
      182 => ["Palestinian Territory, Occupied", 970],
      198 => ["Saint Helena, Ascension and Tristan da Cunha", nil],
      207 => ["South Sudan", 211],
      208 => ["Sao Tome and Principe", 239],
      210 => ["Sint Maarten (Dutch part)", 1721],
      211 => ["Syrian Arab Republic", 963],
      215 => ["French Southern Territories", nil],
      228 => ["Tanzania, United Republic of", 255],
      237 => ["Venezuela, Bolivarian Republic of", 58],
      238 => ["Virgin Islands, British", 1284],
      239 => ["Virgin Islands, U.S.", 1340],
      242 => ["Wallis and Futuna", 681],
    }
    Country.where('calling_code is null').each do |country|
      calling_code = calling_codes[country.id].second
      puts "For #{country.name} using calling code #{calling_code}"
      country.update_column(:calling_code, calling_code)
    end
  end

end

