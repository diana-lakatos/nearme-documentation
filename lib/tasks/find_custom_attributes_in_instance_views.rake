namespace :find_custom_attributes do
  task :in_instance_views => [:environment] do
    hash = {}
    Instance.find_each do |i|
      i.set_context!
      attributes_regexp = CustomAttributes::CustomAttribute.pluck(:name).uniq.join("|")
      if attributes_regexp
        puts "Checking #{i.name}"
        regexp = /(transactable|listing|user|administrator|creator)\.(#{attributes_regexp})/
        InstanceView.where(instance_id: i.id).pluck(:id, :body, :path).each do |arr|
          matches = arr[1].scan(regexp)
          if matches.count > 0
            hash[i.id] ||= {}
            hash[i.id][arr[0]] = matches.join(".")
          end
        end
      else
        puts "Skipping #{i.name} - no custom attributes"
      end
    end
    puts "Result: "
    hash.each do |instance, h|
      puts instance
      h.each do |key, value|
        puts "\t#{key} - #{value}"
      end

    end
  end
end

