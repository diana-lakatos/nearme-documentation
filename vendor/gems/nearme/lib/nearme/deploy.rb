require 'pp'

module NearMe
  class Deploy
    attr_accessor :stack_id, :stack_name, :deploy_branch, :migrate, :comment

    def initialize(options = {})
      @stack_name = options[:stack]
      @comment = options[:comment] || ""
      @migrate = options.fetch(:migrate, true)

      if not stack_id.to_s.empty?
        puts "Stack id: #{stack_id} (#{@stack_name})"
      else
        puts "Cannot find stack by name #{@stack_name}"
        exit 1
      end
      @deploy_branch = options[:branch] || stack_app[:app_source][:revision]

      if @deploy_branch
        puts "Branch to deploy: #{@deploy_branch}"
      else
        puts "Cannot find branch to deploy"
        exit 2
      end

      puts "Migrate: #{migrate}"
      puts "Comment: #{comment}"
    end

    def opsworks_client
      @opsworks_client ||= AWS.ops_works.client
    end

    def stacks
      @stacks ||= opsworks_client.describe_stacks.data.fetch(:stacks, {})
    end

    def stack
      @stack ||= stacks.find(-> {{}}) {|stack| stack[:name] == @stack_name}
    end

    def apps
      @apps ||= opsworks_client.describe_apps(stack_id: stack_id).fetch(:apps, {})
    end

    def stack_id
      @stack_id ||= stack.fetch(:stack_id, {})
    end

    def stack_app
      @stack_app ||= apps.first
    end

    def stack_app_id
      @stack_app_id ||= stack_app.fetch(:app_id, {})
    end

    def start!
      response = opsworks_client.create_deployment(
        stack_id: stack_id,
        app_id: stack_app_id,
        command: {
          name: "deploy",
          args: {
            'migrate' => [@migrate.to_s]
          }
        },
        comment: "#@comment (deployed by NearMe tool at #{Time.now})",
        custom_json: {"deploy" => {stack_app[:shortname] => {"scm" => {"revision" => @deploy_branch}}}}.to_json
      )
    end

    def watch!(deployment_id)
      while deploy_running?(deployment_id)
        print "."
        sleep 20
      end
      print "\n"
      result = opsworks_client.describe_commands(deployment_id: deployment_id)
      pp result.data[:commands][0]
    end

    def deploy_running?(deployment_id)
      result = opsworks_client.describe_commands(deployment_id: deployment_id)
      !result.data[:commands][0].has_key?(:completed_at)
    end
  end
end
