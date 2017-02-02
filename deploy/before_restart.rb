node[:deploy].each do |application, deploy|
  # comment for now because something is wrong when symlink is active
  #   execute "Create symbolic link to shared/node_modules" do
  #     cwd         deploy[:current_path]
  #     group       deploy[:group]
  #     user        deploy[:user]
  #     command     "ln -s #{::File.join(deploy[:deploy_to], 'shared', 'node_modules')} ."
  #     action      :run
  #     only_if     { node["opsworks"]["instance"]["layers"].include?('rails-app') }
  #   end

  execute 'Invoke yarn ' do
    cwd deploy[:current_path]
    user deploy[:user]
    group deploy[:group]
    environment ({ 'HOME' => '/home/deploy', 'USER' => 'deploy', 'PATH' => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/deploy/.local/bin:/home/deploy/bin' })
    command 'yarn install --force'
    action :run
    only_if     { node['opsworks']['instance']['layers'].include?('rails-app') || node['opsworks']['instance']['layers'].include?('utility') }
  end

  # We need public/assets/manifest.json on the utility instance as well otherwise certain images will be missing
  # from emails sent by delayed jobs
  execute "Invoke gulp build:#{node[:deploy][application][:rails_env].downcase} #{deploy['environment']['ASSET_HOST'] ? '--asset_host ' + deploy['environment']['ASSET_HOST'] : ''}" do
    cwd deploy[:current_path]
    user deploy[:user]
    group deploy[:group]
    environment ({ 'HOME' => '/home/deploy', 'USER' => 'deploy', 'PATH' => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/deploy/.local/bin:/home/deploy/bin' })
    command "gulp build:#{node[:deploy][application][:rails_env].downcase} #{deploy['environment']['ASSET_HOST'] ? '--asset_host ' + deploy['environment']['ASSET_HOST'] : ''}"
    action :run
    only_if     { node['opsworks']['instance']['layers'].include?('rails-app') || node['opsworks']['instance']['layers'].include?('utility') }
  end
end
