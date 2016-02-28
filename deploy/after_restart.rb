node[:deploy].each do |application, deploy|

  execute "Invoke rake tasks #{application} [#{node[:deploy][application][:rails_env]} | #{node["opsworks"]["instance"]["layers"]}]" do
    cwd         deploy[:current_path]
    environment({ "RAILS_ENV" => node[:deploy][application][:rails_env] })
    command     "bundle exec rake after_deploy:run opsworks_instance='#{node["opsworks"]["instance"].to_json}'"
    action      :run
    # we want to invoke this only on one server. We check if env is production, in which case we invoke it on utility only. If env is staging, we invoke it on rails-app
    only_if { (node["opsworks"]["instance"]["layers"].include?('rails-app') && node[:deploy][application][:rails_env] == 'staging') || (node["opsworks"]["instance"]["layers"].include?('utility') && node[:deploy][application][:rails_env] == 'production') }
  end

end
