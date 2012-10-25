namespace :db do
  namespace :pull do
    desc "Drops the current database and replaces it with production"
    task :production do
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      system('heroku db:pull --app desksnearme --confirm desksnearme')
    end
    desc "Drops the current database and replaces it with staging"
    task :staging do
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      system('heroku db:pull --app desksnearme-staging --confirm desksnearme-staging')
    end
  end
  namespace :push do
    desc "Drops the staging environments shared database and replaces it with the local one"
    task :staging do
      system('heroku pg:reset HEROKU_POSTGRESQL_GRAY --app desksnearme-staging --confirm desksnearme-staging')
      system('heroku db:push --app desksnearme-staging --confirm desksnearme-staging')
    end
    task :production do
      system('heroku pg:reset postgres://u7ruvrnnngsis:p8ga7rfveikkebenhk2uvo8u6o0@ec2-107-22-220-217.compute-1.amazonaws.com:5542/d8jihti4322eps --app desksnearme --confirm desksnearme')
      system('heroku db:push --app desksnearme --confirm desksnearme')
    end
  end
  namespace :sync do
    desc "Synchronizes production database to the staging server"
    task :production_to_staging do
      Rake::Task["db:pull:production"].invoke
      Rake::Task["db:push:staging"].invoke
      system("heroku run rake db:migrate --app desksnearme-staging")
    end
  end
end
