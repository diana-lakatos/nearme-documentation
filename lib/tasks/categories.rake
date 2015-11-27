namespace :categories do
  desc "fix categories after introducing many to many"
  task :fix => :environment do
    puts 'Fixing categories started...'
    Instance.find_each do |i|
      i.set_context!
      puts "Processing instance: #{i.name}"
      Category.find_each do |category|
        if category.category_linkings.count == 0
          puts "\tProccessing #{category.name}"
          categorizable = category.categorizable_type.constantize.find(category.categorizable_id) rescue nil
          if categorizable
            puts "\t\tassigning #{categorizable.name}"
            CategoryLinking.create!(category: category, category_linkable: categorizable)
            if category.shared_with_users
              puts "\t\tassigning also #{i.default_profile_type.name}"
              CategoryLinking.create!(category: category, category_linkable: i.default_profile_type)
            end
          else
            puts "\tAborting processing #{category.name} - categorizable could not be found"
          end
        else
          puts "\tCategory #{category.name} has been already processed"
        end
      end
    end
  end
end
