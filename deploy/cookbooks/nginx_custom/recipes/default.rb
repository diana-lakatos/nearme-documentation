# cookbooks/nginx_custom/recipes/default.rb
#
# Cookbook Name: nginx-custom
# Recipe: default
#

service "nginx"

if (['app_master', 'app'].include?(node[:instance_role]))
  node[:applications].each do |app_name, app|
    
    template "/etc/nginx/servers/#{app_name}/custom.conf" do
      source 'custom.conf.erb'
      owner 'deploy'
      group 'deploy'
      mode 0644
      backup false
      notifies :reload, resources(services: %w(nginx))
    end
    
    template "/etc/nginx/servers/#{app_name}/custom.ssl.conf" do
      source 'custom.ssl.conf.erb'
      owner 'deploy'
      group 'deploy'
      mode 0644
      backup false
      notifies :reload, resources(services: %w(nginx))
    end
    
  end
end