namespace :release do
  desc "Pushes staging branch to staging server"
  task :staging do
    system('git push staging staging:master')
  end
  desc "Enables maintenance mode, pushes production branch to the production server"
  task :production do
    system('heroku maintenance:on --app desksnearme')
    system('git push -f production production:master')
  end
end
