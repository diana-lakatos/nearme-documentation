require 'yaml'

namespace :mpbuilder do
  desc 'Run all configuration methods for marketplace builder'

  task run: :environment do

    unless ENV['config'].presence
      puts "\e[31mConfig path not provided\e[0m"
      next
    end

    config_file = File.expand_path(ENV['config'], Rails.root)

    unless File.file? config_file
      puts "\e[31mConfig file not found\e[0m"
      next
    end

    config = YAML.load_file(config_file)

    instance_id = config["mpbuilder"]["instance_id"]
    theme_path = File.expand_path(config["mpbuilder"]["theme_path"], Rails.root)

    unless File.directory? theme_path
      puts "\e[31mTheme folder not found\e[0m"
      next
    end

    builder = MarketplaceBuilder.new(instance_id, theme_path)
    builder.run
  end
end
