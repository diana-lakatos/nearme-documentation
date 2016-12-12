require 'json'

namespace :mpbuilder do
  desc 'Run all configuration methods for marketplace builder'

  task run: :environment do

    unless ENV['source'].presence
      puts "\e[31mConfig path not provided\e[0m"
      next
    end

    source = File.expand_path(ENV['source'], Rails.root)
    config_file = File.join(source, '.mpbuilderrc')

    unless File.directory? source
      puts "\e[31mTheme folder not found: #{source}\e[0m"
      next
    end

    unless File.file? config_file
      puts "\e[31m.mpbuilderrc config file not found at #{config_file}\e[0m"
      next
    end

    config = JSON.parse(File.read(config_file))

    instance_id = config["instance_id"]
    mode = config["mode"] || MarketplaceBuilder::MODE_APPEND

    builder = MarketplaceBuilder::Builder.new(instance_id, source, mode)
    builder.execute!
  end
end
