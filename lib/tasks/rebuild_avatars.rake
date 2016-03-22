desc "Rebuild user avatar versions"
task rebuild_avatars: :environment do

  5.times{puts}
  puts "Rebuilding user avatars (#{User.count})"

  failed = []
  User.find_each do |u|
    begin
      # check if user has an uploaded avatar
      if u.avatar.file
        u.avatar.recreate_versions!
        u.save!
      end
      print "."
    rescue
      print "E"
      failed.push(u.id)
    end
  end
  if failed
    puts
    puts "Unable to recreate avatar versions for users: #{failed.sort.join(',')}"
  end
end
