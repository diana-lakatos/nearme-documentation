if %w(app_master app solo).include?(node[:instance_role])
  
  enable_package "app-admin/newrelic-sysmond" do
    version "#{node[:newrelic][:version]}"
  end
  
  package "app-admin/newrelic-sysmond" do
    action :install
    version "#{node[:newrelic][:version]}"
  end
  
  template "/etc/newrelic/nrsysmond.cfg" do
    source "nrsysmond.cfg.erb"
    owner 'root'
    group 'root'
    mode 0644
    backup 0
    variables(
      :key   => 'd37590e50f88575698b56c3aab713e5bd491afb8')
  end
  
  remote_file "/etc/monit.d/nrsysmond.monitrc" do
    owner "root"
    group "root"
    mode 0644
    backup 0
    source "nrsysmond.monitrc"
  end
  
  directory "/var/log/newrelic" do
    action :create
    recursive true
    owner 'root'
    group 'root'
  end
  
  execute "monit reload" do
    action :run
  end
  
end
