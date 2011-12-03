desc "Run all the steps necessary for the CI"
task :ci => [ :cucumber, :spec ]
