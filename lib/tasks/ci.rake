desc "Run all the steps necessary for the CI"
file 'config/database.yml' do
    # set up database.yml
    FileUtils.cp('config/database.ci.yml', 'config/database.yml')
end

task :ci => [ 'config/database.yml', 'ts:conf', :cucumber, :spec ]
