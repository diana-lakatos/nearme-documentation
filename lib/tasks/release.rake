namespace :release do
  desc "Pushes staging branch to staging server"
  task :staging do
    system('git push staging staging:master')
  end
  desc "Enables maintenance mode, pushes production branch to the production server"
  task :production do
    puts "Preparing to deploy to production."
    puts "Enable maintenance mode? Type 'yes' or 'no'"
    print '> '
    maintenance = STDIN.gets.chomp == "yes"

    if maintenance
      puts "Deploying with maintenance mode ON"
      system('heroku maintenance:on --app desksnearme')
    else
      puts "Deploying with maintnenance mode OFF"
    end

    system('git push -f production production:master')
    puts "Deploy finished."

    if maintenance
      puts "Maintenance mode was ON. Turn maintenance mode off? Type 'yes' or 'no'"
      print '> '
      disable = STDIN.gets.chomp == "yes"
      if disable
        puts "Disabling maintenance mode"
        system('heroku maintenance:off --app desksnearme')
      else
        puts "Leaving maintenance mode ON"
      end
    end
  end
end
