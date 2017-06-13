
execute 'Invoke yarn' do
  cwd new_resource.current_path
  user new_resource.user
  group new_resource.group
  environment ({ 'HOME' => '/home/deploy', 'USER' => 'deploy', 'PATH' => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/deploy/.local/bin:/home/deploy/bin' })
  command 'yarn install --force --frozen-lockfile'
  action :run
  only_if     { node['opsworks']['instance']['layers'].include?('rails-app') }
end

# We need public/assets/manifest.json on the utility instance as well otherwise certain images will be missing
# from emails sent by delayed jobs
execute "Invoke gulp build:#{new_resource.environment['RAILS_ENV'].downcase} #{new_resource.environment['ASSET_HOST'] ? '--asset_host ' + new_resource.environment['ASSET_HOST'] : ''}" do
  cwd new_resource.current_path
  user new_resource.user
  group new_resource.group
  environment ({ 'HOME' => '/home/deploy', 'USER' => 'deploy', 'PATH' => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/deploy/.local/bin:/home/deploy/bin' })
  command "gulp build:#{new_resource.environment['RAILS_ENV'].downcase} #{new_resource.environment['ASSET_HOST'] ? '--asset_host ' + new_resource.environment['ASSET_HOST'] : ''}"
  action :run
  only_if     { node['opsworks']['instance']['layers'].include?('rails-app') }
end
