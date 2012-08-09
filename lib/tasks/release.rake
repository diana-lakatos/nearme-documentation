namespace :release do
  desc "Pushes staging branch to staging server and migrates the database"
  task :staging do
    exec('git push staging staging:master')
    exec('heroku run rake db:migrate --app desksnearme-staging')
  end
end
