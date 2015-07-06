namespace :rating_systems do
  desc "Create rating systems if missing, safe to use, won't override anything"
  task create: :environment do
    Instance.find_each do |instance|
      instance.set_context!
      puts "Processing #{instance.name} (id=#{instance.id})"
      TransactableType.find_each do |transactable_type|
        if transactable_type.rating_systems.count.zero?
          puts "\tTransactableType #{transactable_type.class.name} id=#{transactable_type.id} has no rating systems, creating..."
          transactable_type.create_rating_systems
        end
      end
    end
  end
end
