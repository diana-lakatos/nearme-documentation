node[:deploy].each do |application, deploy|

  execute "Create symbolic link to shared/node_modules" do
    cwd         deploy[:current_path]
    group       deploy[:group]
    user        deploy[:user]
    command     "ln -s #{::File.join(deploy[:deploy_to], 'shared', 'node_modules')} ."
    action      :run
    only_if     { node["opsworks"]["instance"]["layers"].include?('rails-app') }
  end

  execute "Invoke npm install " do
    cwd         deploy[:current_path]
    user        deploy[:user]
    group       deploy[:group]
    environment ({'HOME' => '/home/deploy', 'USER' => 'deploy', 'PATH' => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/deploy/.local/bin:/home/deploy/bin'})
    command     "cd /srv/www/nearme/current/ && npm install"
    action      :run
    only_if     { node["opsworks"]["instance"]["layers"].include?('rails-app') }
  end

  execute "Invoke gulp dist" do
    cwd         deploy[:current_path]
    user        deploy[:user]
    group       deploy[:group]
    environment ({'HOME' => '/home/deploy', 'USER' => 'deploy', 'PATH' => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/deploy/.local/bin:/home/deploy/bin'})
    command     "cd /srv/www/nearme/current/ && gulp dist"
    action      :run
    only_if     { node["opsworks"]["instance"]["layers"].include?('rails-app') }
  end

  execute "Invoke rake webpack" do
    cwd         deploy[:current_path]
    user        deploy[:user]
    group       deploy[:group]
    environment({ "RAILS_ENV" => node[:deploy][application][:rails_env] })
    command     "bundle exec rake webpack:compile"
    action      :run
    only_if     { node["opsworks"]["instance"]["layers"].include?('rails-app') }
  end

end

