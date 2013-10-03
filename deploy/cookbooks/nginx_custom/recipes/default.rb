# cookbooks/nginx_custom/recipes/default.rb
#
# Cookbook Name: nginx_custom
# Recipe: default
#
require 'chef/util/file_edit'

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

    ruby_block "use custom CORS for webfonts" do
      block do
        banner = "# set Expire header on assets: see http://developer.yahoo.com/performance/rules.html#expires"
        custom_cors = <<CORS
  # custom CORS policy for webfonts in Firefox
  location ~* \.(eot|ttf|woff)$ {
    add_header Access-Control-Allow-Origin *;
  }
CORS
        files = [
          "/etc/nginx/servers/#{app_name}.ssl.conf",
          "/etc/nginx/servers/#{app_name}.conf"
        ]

        files.each do |file|
          chef_file = Chef::Util::FileEdit.new(file)
          chef_file.search_file_replace_line(
            banner,
            "#{custom_cors}\n  #{banner}"
          )
          chef_file.write_file unless File.readlines(file).grep(/CORS/).any?
        end
      end
    end

    execute 'sudo /etc/init.d/nginx reload'
    
  end
  
end
