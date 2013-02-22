#
# Cookbook Name:: resque
# Recipe:: default
#
if node[:instance_role] == 'util'
  
  worker_count = case node[:ec2][:instance_type]
  when 'm1.small' then 1
  when 'c1.medium'then 2
  when 'c1.xlarge' then 4
  else 2
  end
  
  node[:applications].each do |app, data|
    template "/etc/monit.d/resque_#{app}.monitrc" do
      owner 'root' 
      group 'root' 
      mode 0644 
      source "monitrc.conf.erb" 
      variables({ 
        :num_workers => worker_count,
        :app_name => app, 
        :rails_env => node[:environment][:framework_env] 
      }) 
    end
    
    worker_count.times do |count|
      template "/data/#{app}/shared/config/resque_#{count}.conf" do
        owner node[:owner_name]
        group node[:owner_name]
        mode 0644
        source "resque_wildcard.conf.erb"
      end
    end
    
    execute "ensure-resque-is-setup-with-monit" do 
      epic_fail true
      command %Q{ 
      monit reload 
      } 
    end
  end 
end
