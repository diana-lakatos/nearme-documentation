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

    # Manually add ssl certs and keys for nearme (EY only supports one key per env in the dashboard)
    cookbook_file "/etc/nginx/ssl/nearme.crt" do
      source "nearme.crt"
      action :create
      owner node[:owner_name]
      mode 0644
      backup false
    end

    cookbook_file "/etc/nginx/ssl/nearme.key" do
      source "nearme.key"
      action :create
      owner node[:owner_name]
      mode 0644
      backup false
    end

    # Manually add ssl certs and keys for reggalo (EY only supports one key per env in the dashboard)
    cookbook_file "/etc/nginx/ssl/reggalo.crt" do
      source "reggalo.crt"
      action :create
      owner node[:owner_name]
      mode 0644
      backup false
    end

    cookbook_file "/etc/nginx/ssl/reggalo.key" do
      source "reggalo.key"
      action :create
      owner node[:owner_name]
      mode 0644
      backup false
    end

    # Add a server block for ssl secured https://near-me.com
    template "/etc/nginx/servers/nearme.ssl.conf" do
      source "nearme.ssl.conf.erb"
      action :create
      owner node[:owner_name]
      mode 0644
      variables({
        :instance_role => node[:instance_role]
      })
    end

    # Add a server block for ssl secured https://near-me.com
    template "/etc/nginx/servers/reggalo.ssl.conf" do
      source "reggalo.ssl.conf.erb"
      action :create
      owner node[:owner_name]
      mode 0644
      variables({
        :instance_role => node[:instance_role]
      })
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

        custom_gzip_serving = <<GZIP
  location ^~ /assets/ {
    # Only use gzip_static if you have .gz compressed assets *precompiled*
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }
GZIP
        files = [
          "/etc/nginx/servers/#{app_name}.ssl.conf",
          "/etc/nginx/servers/#{app_name}.conf"
        ]

        files.each do |file|
          chef_file = Chef::Util::FileEdit.new(file)
          chef_file.search_file_replace_line(
            banner,
            "#{custom_cors}\n  #{custom_gzip_serving}\n  #{banner}"
          )
          chef_file.write_file unless File.readlines(file).grep(/CORS/).any?
        end
      end
    end

    execute 'sudo /etc/init.d/nginx reload'

  end

end
