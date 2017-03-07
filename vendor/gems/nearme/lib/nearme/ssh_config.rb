require 'pp'
require 'aws-sdk'
require 'erb'

module NearMe
  class SshConfig
    def update
      instances.group_by { |instance| instance.stack }.map do |stack, instances|
        jump = jump_servers.find { |s| s.stack.region == stack.region }
        erb_template.result(binding)
      end.tap do |output|
        update_ssh_config output.join("\n")
      end
    end

    def instances
      aws.instances.reject(&:jump?)
    end

    def jump_servers
      aws.instances.select(&:jump?)
    end

    private

    def update_ssh_config(config)
      orig = File.read(ENV['HOME'] + '/.ssh/config')

      orig << wrapper('') unless orig.include? 'BEGIN-NM-STACK'

      File.open(File.join(ENV['HOME'], '/.ssh/config'), 'w') do |file|
        file.write orig.gsub(/# BEGIN-NM-STACK.*# END-NM-STACK/m, wrapper(config))
      end
    end

    def wrapper(config)
      "# BEGIN-NM-STACK\n#{config}# END-NM-STACK\n"
    end

    def erb_template
      ERB.new(File.read(File.join(File.dirname(__FILE__), 'ssh_config.erb')))
    end

    def aws
      @aws ||= AwsClient.new
    end

    class AwsClient
      def instances
        @instances ||= stacks.flat_map do |stack|
          puts 'Fetching instance list from: ', stack.name
          stack_instances(stack.stack_id).map do |instance|
            InstanceDecorator.new(instance, stack)
          end
        end
      end

      private

      def stacks
        @stacks ||= client.describe_stacks.data.stacks
      end

      def stack_instances(stack_id)
        client
          .describe_instances(stack_id: stack_id)
          .data
          .instances
      end

      def client
        @client ||= Aws::OpsWorks::Client.new region: 'us-east-1'
      end

    end

    class InstanceDecorator < SimpleDelegator
      attr_reader :stack
      def initialize(object, stack)
        super(object)
        @stack = stack
      end

      def hostname
        format('%s-%s', stack.name, __getobj__.hostname)
      end

      def private_ip
        __getobj__.private_ip || 'missing-private-ip'
      end

      def jump?
        __getobj__.hostname =~ /jump/
      end
    end
  end
end
