namespace :release do
  desc "Pushes staging branch to staging server and migrates the database"
  task :staging do
    system('git push staging staging:master')
    Rake::Task["db:sync:production_to_staging"].invoke
    Rake::Task["db:seed"].invoke
  end
end
