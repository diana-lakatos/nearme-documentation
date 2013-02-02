# New Relic deployment notification
on_app_master do
  description = (`cd #{current_path} && git log -1 --format="%s"`).chomp
  run "cd #{current_path} && bundle exec newrelic deployments --user='#{deployed_by}' --revision='#{revision}' '#{description}'"
end

# Must restart utilities that require the environment
sudo "monit -g dj_#{app} restart all"