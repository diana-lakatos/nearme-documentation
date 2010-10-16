desc "Run all the steps necessary for the CI"
task :ci do
  ENV["RAILS_ENV"] ||= "test"
  tasks = %w[db:drop db:create db:schema:load db:migrate cucumber spec]
  tasks.each {|task| Rake::Task[task].invoke}
end