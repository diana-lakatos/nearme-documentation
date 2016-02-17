node[:deploy].each do |application, deploy|
# comment for now because something is wrong when symlink is active
=begin
  execute "Create symbolic link to shared/node_modules" do
    cwd         deploy[:current_path]
    group       deploy[:group]
    user        deploy[:user]
    command     "ln -s #{::File.join(deploy[:deploy_to], 'shared', 'node_modules')} ."
    action      :run
    only_if     { node["opsworks"]["instance"]["layers"].include?('rails-app') }
  end
=end

  execute "Invoke npm install " do
    cwd         deploy[:current_path]
    user        deploy[:user]
    group       deploy[:group]
    environment ({'HOME' => '/home/deploy', 'USER' => 'deploy', 'PATH' => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/deploy/.local/bin:/home/deploy/bin'})
    command     "cd /srv/www/nearme/current/ && npm install"
    action      :run
    only_if     { node["opsworks"]["instance"]["layers"].include?('rails-app') }
  end

  execute "Invoke gulp build" do
    cwd         deploy[:current_path]
    user        deploy[:user]
    group       deploy[:group]
    environment ({'HOME' => '/home/deploy', 'USER' => 'deploy', 'PATH' => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/deploy/.local/bin:/home/deploy/bin'})
    command     "cd /srv/www/nearme/current/ && gulp build:#{node[:deploy][application][:rails_env].downcase}"
    action      :run
    only_if     { node["opsworks"]["instance"]["layers"].include?('rails-app') }
  end
end

