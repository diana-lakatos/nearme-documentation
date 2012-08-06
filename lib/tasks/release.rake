namespace :release do
  task :staging do
    `git push staging staging:master`
    `heroku run --app desksnearme-staging rake db:migrate`
  end
end
