node[:deploy].each do |application, deploy|
  execute "Invoke rake tasks #{node['opsworks']['instance']['layers']}.include?('utility') && #{node[:deploy][application][:rails_env]} == 'production' => #{(node['opsworks']['instance']['hostname'].include?('rails-qa') && node[:deploy][application][:rails_env] == 'staging') || (node['opsworks']['instance']['layers'].include?('utility') && %w(production staging).include?(node[:deploy][application][:rails_env]))}]" do
    cwd deploy[:current_path]
    environment('RAILS_ENV' => node[:deploy][application][:rails_env])
    command 'bundle exec rake after_deploy:run'
    action :run
    # we want to invoke this only on one server. We check if env is production, in which case we invoke it on utility only. If env is staging, we invoke it on rails-app
    only_if { (node['opsworks']['instance']['hostname'].include?('rails-qa') && node[:deploy][application][:rails_env] == 'staging') || (node['opsworks']['instance']['layers'].include?('utility') && %w(production staging).include?(node[:deploy][application][:rails_env])) }
  end

  execute "generate documentation" do
    cwd deploy[:current_path]
    environment('RAILS_ENV' => node[:deploy][application][:rails_env])
    command 'bundle exec rake documentation:frontend_docs'
    action :run
    only_if { node['opsworks']['instance']['layers'].include?('rails-app') }
  end
end
