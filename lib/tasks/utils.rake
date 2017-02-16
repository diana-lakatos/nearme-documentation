namespace :utils do
  task :delete_test_users, [:instance_id, :users_file] => [:environment] do |_t, args|
    def prompt(*args)
      print(*args)
      STDIN.gets.chomp
    end

    instance_id = args[:instance_id]
    users_file = args[:users_file].to_s

    instance = Instance.find(instance_id)
    instance.set_context!
    puts "Set context to instance: #{instance.name}"

    if !File.exists?(users_file)
      puts "File not found: #{users_file}"
      exit
    end

    CSV.foreach(users_file) do |row|
      puts "At user with id: #{row[0]}, email: #{row[1]}"
      user = User.with_deleted.find_by(id: row[0])
      if user.blank?
        puts "User not found. Skipping..."
        next
      end
      if user.email != row[1]
        puts "Skipping user, email mismatch #{user.email} != #{row[1]}"
        next
      end
      if user.admin?
        puts "Skipping user, is global ADMIN!"
        next
      end

      answer = prompt("Are you sure you want to delete user with id: #{user.id}, email: #{user.email}? ").downcase

      case answer
      when 'y'
        puts "Deleting..."
        user.really_destroy!
      when 'quit'
        exit
      else
        puts "Skipping..."
        next
      end
    end
  end
end
