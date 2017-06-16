
file 'Create shared/config/application.yml'  do
  path "#{::File.join(new_resource.deploy_to, 'shared', 'config', 'application.yml')}"
  group new_resource.group
  owner new_resource.user
  mode '0660'
  content YAML.dump(new_resource.environment.to_hash))
end

directory 'Create shared/node_modules' do
  path "#{::File.join(new_resource.deploy_to, 'shared', 'node_modules')}"
  mode '0770'
  group new_resource.group
  owner new_resource.user
end
