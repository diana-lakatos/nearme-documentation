desc "Adds project thumbnail with fixed size"
task add_project_thumb_fixed_size: :environment do
  5.times{puts}
  Instance.find_each do |i|
    i.set_context!

    Project.find_each do |project|
      project.photos.find_each do |photo|
      photo.image.recreate_versions! rescue nil
        photo.save(validate: false)
      end
    end

    User.find_each do |user|
      user.avatar.recreate_versions! rescue nil
      user.save(validate: false)
    end
  end
end
