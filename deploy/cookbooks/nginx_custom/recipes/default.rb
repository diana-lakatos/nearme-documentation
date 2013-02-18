# cookbooks/nginx_custom/recipes/default.rb
#
# Cookbook Name: nginx-custom
# Recipe: default
#

if (['app_master', 'app'].include?(node[:instance_role]))
  node[:engineyard][:environment][:apps].each do |app|
    template "/etc/nginx/servers/#{app[:name]}/custom.conf" do
      source 'custom.conf.erb'
      owner 'deploy'
      group 'deploy'
      mode 0644
    end
    
    template "/etc/nginx/servers/#{app[:name]}/custom.ssl.conf" do
      source 'custom.ssl.conf.erb'
      owner 'deploy'
      group 'deploy'
      mode 0644
    end
    
    execute "sudo /etc/init.d/nginx reload"
  end
end