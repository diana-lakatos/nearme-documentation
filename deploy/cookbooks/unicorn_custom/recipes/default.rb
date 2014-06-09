# cookbooks/unicorn_custom/recipes/default.rb
#
# Cookbook Name: unicorn_custom
# Recipe: default
#
if %w(app_master app solo).include?(node[:instance_role])
  node[:applications].each do |app_name, app|
    cookbook_file "/data/#{app_name}/shared/config/unicorn.rb" do
      source 'unicorn.rb'
      owner node[:owner_name]
      mode 0644
      backup false
    end
  end
end
