# frozen_string_literal: true
require 'pp'
require 'aws-sdk'

module NearMe
  class Backup
    def initialize(options = {})
      @stack_name = options[:stack]
      @host_name = options[:host] || stack_to_host_mapping[@stack_name]
      @environment = options[:environment] || stack_to_env_mapping[@stack_name]
      @jump_stack_name = stack_name_to_jump_stack_name(@stack_name)

      if ENV['AWS_USER'].nil?
        puts 'You must set the AWS_USER enviroment variable for AWS.'
        exit 1
      end

      if ENV['AWS_ACCESS_KEY_ID'].nil?
        puts 'You must set the AWS_ACCESS_KEY_ID enviroment variable for AWS.'
        exit 1
      end

      if ENV['AWS_SECRET_ACCESS_KEY'].nil?
        puts 'You must set the AWS_SECRET_ACCESS_KEY enviroment variable for AWS.'
        exit 1
      end

      if !stack_id.nil?
        puts "Stack id: #{stack_id} (#{@stack_name})"
      else
        puts "Cannot find stack by name #{@stack_name}"
        exit 1
      end

      if !instance.empty?
        puts "Instance found for host #{@host_name}"
      else
        puts "Cannot find instance for host #{@host_name}"
        exit 1
      end

      if !public_dns.empty?
        puts "Public dns (#{public_dns}) found for host #{@host_name}"
      else
        puts "Cannot find public dns for host #{@host_name}"
        exit 1
      end
    end

    # This maps the default host (ec2 instance) we want the scripts to run on for a stack
    def stack_to_host_mapping
      {
        'nm-production' => 'california-utility1',
        'nm-oregon' => 'oregon-rails-app1',
        'nm-sydney' => 'sydney-rails-app1',
        'nm-staging' => 'rails-app1',
        'nm-qa-1' => 'rails-app1',
        'nm-qa-2' => 'rails-qa2',
        'nm-qa-3' => 'rails-qa3'
      }
    end

    def stack_name_to_jump_stack_name(stack_name)
      case stack_name
      when 'nm-oregon' then 'nm-jump-oregon'
      when 'nm-sydney' then 'nm-jump-sydney'
      else
        'nm-jump'
      end
    end

    # This maps the default rails env we want the scripts to run in for a stack
    def stack_to_env_mapping
      {
        'nm-production' => 'production',
        'nm-oregon' => 'production',
        'nm-sydney' => 'production',
        'nm-staging' => 'staging',
        'nm-qa-1' => 'staging',
        'nm-qa-2' => 'staging',
        'nm-qa-3' => 'staging'
      }
    end

    def opsworks_client
      @opsworks_client ||= Aws::OpsWorks::Client.new region: ENV['AWS_OPSWORKS_REGION']
    end

    def stacks
      @stacks ||= opsworks_client.describe_stacks.data.stacks
    end

    def stack
      @stack ||= stacks.find(-> { {} }) { |stack| stack.name == @stack_name }
    end

    def stack_id
      @stack_id ||= stack.stack_id
    end

    def instances
      @instances ||= opsworks_client.describe_instances(stack_id: stack_id).data.instances
    end

    def instance
      @instance ||= instances.find(-> { {} }) { |instance| instance.hostname == @host_name }
    end

    def jump_server_dns
      jump_stack_id = opsworks_client.describe_stacks.data.stacks.find(-> { {} }) { |stack| stack.name == @jump_stack_name }.stack_id
      opsworks_client.describe_instances(stack_id: jump_stack_id).data.instances.first.public_dns
    end

    def public_dns
      @public_dns ||= instance.public_dns
    end

    def capture!
      puts 'Creating remote db dump...'
      remote_command = "sudo -H -u deploy bash -c 'cd /srv/www/nearme/current && AWS_ACCESS_KEY_ID=#{ENV['AWS_ACCESS_KEY_ID']} AWS_SECRET_ACCESS_KEY=#{ENV['AWS_SECRET_ACCESS_KEY']} RAILS_ENV=#{@environment} bundle exec rake backup:capture'"
      puts remote_command
      run_remote_command(remote_command)
    end

    def restore!
      if @stack_name == 'nm-production'
        puts '[Error] This tool is not meant to restore to the production db.'
        exit 1
      end

      puts 'Restoring remote db dump...'
      remote_command = "sudo -H -u deploy bash -c 'cd /srv/www/nearme/current && AWS_ACCESS_KEY_ID=#{ENV['AWS_ACCESS_KEY_ID']} AWS_SECRET_ACCESS_KEY=#{ENV['AWS_SECRET_ACCESS_KEY']} RAILS_ENV=#{@environment} bundle exec rake backup:restore'"
      run_remote_command(remote_command)

      puts 'Adding stack domains...'
      remote_command = "sudo -H -u deploy bash -c 'cd /srv/www/nearme/current && RAILS_ENV=#{@environment} bundle exec rake backup:create_stack_domains[#{@stack_name}] '"
      run_remote_command(remote_command)
    end

    private

    def run_remote_command(remote_command)
      unless Kernel.system("ssh -t -o ProxyCommand='ssh #{ENV['AWS_USER']}@#{jump_server_dns} -W %h:%p' #{ENV['AWS_USER']}@#{public_dns} \"#{remote_command}\"")
        puts 'Remote command failed.'
        exit 1
      end
    end
  end
end
