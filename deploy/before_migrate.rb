node[:deploy].each do |app, deploy|

  file "Create shared/config/application.yml"  do
    path    "#{::File.join(deploy[:deploy_to], 'shared', 'config', 'application.yml')}"
    group   deploy[:group]
    owner   deploy[:user]
    mode    "0660"
    content YAML.dump(deploy['environment'].to_hash.merge((deploy['custom_env'] || {}).to_hash))
  end

  directory "Create shared/node_modules" do
    path  "#{::File.join(deploy[:deploy_to], 'shared', 'node_modules')}"
    mode  "0770"
    group deploy[:group]
    owner deploy[:user]
  end

  execute "Create symbolic link to shared/node_modules" do
    cwd         deploy[:current_path]
    group       deploy[:group]
    user        deploy[:user]
    command     "ln -s #{::File.join(deploy[:deploy_to], 'shared', 'node_modules')} ."
    action      :run
    only_if     { node["opsworks"]["instance"]["layers"].include?('rails-app') }
  end

end

