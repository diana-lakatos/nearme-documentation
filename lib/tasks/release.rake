namespace :release do
  desc "Pushes staging branch to staging server and migrates the database"
  task :staging do
    system('git push staging staging:master')
  end
end
