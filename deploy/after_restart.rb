log 'new_resource' do
  message new_resource.to_json
  level :warn
end

execute "Invoke rake tasks #{node['opsworks']['instance']['layers']}.include?('utility') && #{new_resource.environment['RAILS_ENV'].downcase} == 'production' => #{(node['opsworks']['instance']['hostname'].include?('rails-qa') && new_resource.environment['RAILS_ENV'].downcase == 'staging') || (node['opsworks']['instance']['layers'].include?('utility') && %w(production staging).include?(new_resource.environment['RAILS_ENV'].downcase))}]" do
  cwd new_resource.current_path
  environment('RAILS_ENV' => new_resource.environment['RAILS_ENV'])
  command 'bundle exec rake after_deploy:run'
  action :run
  # we want to invoke this only on one server. We check if env is production, in which case we invoke it on utility only. If env is staging, we invoke it on rails-app
  only_if { (node['opsworks']['instance']['hostname'].include?('rails-qa') && new_resource.environment['RAILS_ENV'].downcase == 'staging') || (node['opsworks']['instance']['layers'].include?('utility') && %w(production staging).include?(new_resource.environment['RAILS_ENV'].downcase)) }
end

execute "generate documentation" do
  cwd new_resource.current_path
  environment('RAILS_ENV' => new_resource.environment['RAILS_ENV'])
  command 'bundle exec rake documentation:frontend_docs'
  action :run
  only_if { node['opsworks']['instance']['layers'].include?('rails-app') }
end
