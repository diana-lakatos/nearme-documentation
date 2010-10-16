desc "Run all the steps necessary for the CI"
task :ci do
  ENV["RAILS_ENV"] ||= "test"
  %w[db:create cucumber spec].each {|task| Rake::Task[task].invoke}
end
