# frozen_string_literal: true
require 'pp'

# TODO: test deploying, remove comment after successful deploy

module NearMe
  class Deploy
    attr_accessor :stack_id, :stack_name, :deploy_branch, :migrate, :comment,
                  :app_name

    def initialize(options = {})
      @stack_name = options[:stack]
      @app_name = options[:app_name]
      @comment = options[:comment] || ''
      @migrate = options.fetch(:migrate, true)

      if stack_id.present?
        puts "Stack id: #{stack_id} (#{@stack_name})"
      else
        puts "Cannot find stack by name #{@stack_name}"
        exit 1
      end

      if stack_app.present?
        puts "Application id: #{stack_app_id} (#{stack_app.shortname})"
      else
        puts "Cannot find app by name #{@app_name}" if @app_name
        puts "Available apps are: #{app_names}"
        exit 1
      end

      @deploy_branch = options[:branch] || stack_app[:app_source][:revision]

      if @deploy_branch
        puts "Branch to deploy: #{@deploy_branch}"
      else
        puts 'Cannot find branch to deploy'
        exit 2
      end

      puts "Migrate: #{migrate}"
      puts "Comment: #{comment}"

      if apps.size > 1
        other_apps = app_names - Array.wrap(stack_app.shortname)
        puts "--===PLEASE REMEMBER TO DEPLOY OTHER APPS: #{other_apps.join(', ')} ===--"
      end
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

    def apps
      @apps ||= opsworks_client.describe_apps(stack_id: stack_id).apps
    end

    def app_names
      @app_names ||= apps.map(&:shortname)
    end

    def stack_id
      @stack_id ||= stack.stack_id
    end

    def stack_app
      @stack_app ||= if @app_name
                       apps.find { |app| app.shortname == @app_name }
                     else
                       apps.first
                     end
    end

    def stack_app_id
      @stack_app_id ||= stack_app.app_id
    end

    def start!
      opsworks_client.create_deployment(
        stack_id: stack_id,
        app_id: stack_app_id,
        command: {
          name: 'deploy',
          args: {
            'migrate' => [@migrate.to_s]
          }
        },
        comment: "#{@comment} (deployed by NearMe tool at #{Time.now})",
        custom_json: { deploy: { stack_app.shortname => { scm: { revision: @deploy_branch } } } }.to_json
      )
    end

    def watch!(deployment_id)
      while deploy_running?(deployment_id)
        print '.'
        sleep 20
      end
      print "\n"
      result = opsworks_client.describe_commands(deployment_id: deployment_id)
      instance_id_to_name = opsworks_client.describe_instances(stack_id: stack_id).instances.each_with_object({}) do |el, hash|
        hash[el.instance_id] = el.hostname
        hash
      end
      result_hash = result.data.commands.map do |el|
        {
          name: instance_id_to_name[el.instance_id],
          status: el.status,
          log_url: el.log_url
        }
      end

      pp result_hash.inspect
      if apps.size > 1
        other_apps = app_names - Array.wrap(stack_app.shortname)
        puts "--===PLEASE REMEMBER TO DEPLOY OTHER APPS: #{other_apps.join(', ')} ===--"
      end
      result_hash
    end

    def deploy_running?(deployment_id)
      result = opsworks_client.describe_commands(deployment_id: deployment_id)
      # deploy is running if there is at least one pending server we deploy to and nothing failed so far
      result.data.commands.any? { |c| c.status == 'pending' } && result.data.commands.none? { |c| c.status == 'failed' }
    end
  end
end
