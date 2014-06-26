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

    # Add crt, key, and server block for these domains
    {'nearme' => 'near-me.com', 'reggalo' => 'reggalo.com'}.each do |name, domain|

      cookbook_file "/etc/nginx/ssl/#{name}.crt" do
        source "#{name}.crt"
        action :create
        owner node[:owner_name]
        mode 0644
        backup false
      end

      cookbook_file "/etc/nginx/ssl/#{name}.key" do
        source "#{name}.key"
        action :create
        owner node[:owner_name]
        mode 0644
        backup false
      end

      template "/etc/nginx/servers/#{name}.ssl.conf" do
        source "ssl_server.ssl.conf.erb"
        action :create
        owner node[:owner_name]
        mode 0644
        variables({
          instance_role: node[:instance_role],
          name: name,
          domain: domain
        })
      end
    end

    ruby_block "use custom CORS for webfonts" do
      block do
        banner = "# set Expire header on assets: see http://developer.yahoo.com/performance/rules.html#expires"

        custom_assets_config = <<ASSETS
  location ^~ /assets/ {
    # Only use gzip_static if you have .gz compressed assets *precompiled*
    gzip_static on;
    expires max;
    add_header Cache-Control public;

    # custom CORS policy for webfonts in Firefox
    location ~* \.(eot|ttf|woff)$ {
      add_header Access-Control-Allow-Origin *;
    }
  }
ASSETS
        files = [
          "/etc/nginx/servers/#{app_name}.ssl.conf",
          "/etc/nginx/servers/#{app_name}.conf"
        ]

        files.each do |file|
          chef_file = Chef::Util::FileEdit.new(file)
          chef_file.search_file_replace_line(
            banner,
            "#{custom_assets_config}\n  #{banner}"
          )
          chef_file.write_file unless File.readlines(file).grep(/CORS/).any?
        end
      end
    end

    execute 'sudo /etc/init.d/nginx reload'

  end

end
