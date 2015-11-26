namespace :new_ui do
  desc 'Converts instance to new UI'
  task :convert_instance, [:instance_id] => [:environment] do |t, args|
    if args[:instance_id] && instance = Instance.find(args[:instance_id])
      instance.set_context!
      if NewUiConverter.new(instance.id).convert_to_new_ui
        p "Instance ##{instance.id} #{instance.name} has been successfully converted to new ui"
      else
        p "Unable to convert ##{instance.id} #{instance.name}."
      end
    else
      p "No instance found for instance_id #{args[:instance_id]} or instance_id not set"
    end
  end

  desc 'Reverts instance to old UI'
  task :revert_instance, [:instance_id] => [:environment] do |t, args|
    if args[:instance_id] && instance = Instance.find(args[:instance_id])
      instance.set_context!
      if NewUiConverter.new(instance.id).revert_to_old_ui
        p "Instance ##{instance.id} #{instance.name} has been successfully converted to old ui"
      else
        p "Unable to convert ##{instance.id} #{instance.name}."
      end
    else
      p "No instance found for instance_id #{args[:instance_id]} or instance_id not set"
    end
  end

end
