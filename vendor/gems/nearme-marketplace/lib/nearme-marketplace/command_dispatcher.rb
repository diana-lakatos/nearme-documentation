require 'listen'
require 'faraday'
require 'colorize'
require 'json'
require 'fileutils'

require "nearme-marketplace/version"
require "nearme-marketplace/commands/base_command"
require "nearme-marketplace/commands/deploy_command"
require "nearme-marketplace/commands/pull_command"
require "nearme-marketplace/commands/sync_command"

module NearmeMarketplace
  class CommandDispatcher
    def on_user_command
      command_class_by_arg.new.execute!
    end

    private

    def command_class_by_arg
      case ARGV[0]
        when "sync"   then SyncCommand
        when "deploy" then DeployCommand
        when "pull"   then PullCommand
        else abort("Usage: nearme-marketpalce sync | deploy | pull")
      end
    end
  end
end
