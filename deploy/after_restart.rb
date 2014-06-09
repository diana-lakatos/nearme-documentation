# Must restart utilities that require the environment
sudo "monit -g dj_#{config.app} restart all"
warn "monit -g dj_#{config.app} restart all"

# New Relic deployment notification
on_app_master do
  description = (`cd #{config.current_path} && git log -1 --format="%s"`).chomp
  run "cd #{config.current_path} && bundle exec newrelic deployments --user='#{config.deployed_by}' --revision='#{config.revision}' '#{description}'"

  # Recompile the css for each instance's theme
  run "bundle exec rake reprocess:css"
end

