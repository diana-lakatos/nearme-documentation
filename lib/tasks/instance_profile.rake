namespace :instance_profile do
  desc "fix instance profile issue"
  task :fix => :environment do
    puts 'InstanceProfileType correction started...'
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      profile_type = i.instance_profile_types.first_or_create(name: "User Instance Profile")
      User.where(admin: [nil, false]).where('instance_profile_type_id is null').update_all(instance_profile_type_id: profile_type.id)
    end
    puts 'Done'
  end
end
