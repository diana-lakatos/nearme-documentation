# cookbooks/nginx_custom/recipes/default.rb
#
# Cookbook Name: nginx_custom
# Recipe: default
#

if %w(app_master app solo).include?(node[:instance_role])
  
  node[:applications].each do |app_name, app|
    
    template "/etc/nginx/servers/#{app_name}/custom.conf" do
      source 'custom.conf.erb'
      owner node[:owner_name]
      mode 0644
      backup false
    end
    
    template "/etc/nginx/servers/#{app_name}/custom.ssl.conf" do
      source 'custom.ssl.conf.erb'
      owner node[:owner_name]
      mode 0644
      backup false
    end
    
    sudo '/etc/init.d/nginx reload'
    
  end
  
end