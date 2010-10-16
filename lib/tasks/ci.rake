desc "Run all the steps necessary for the CI"
task :ci => [ "ts:conf", :cucumber, :spec ]
