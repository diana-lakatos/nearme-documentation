require 'pp'
require 'aws'

module NearMe
  class Info

    def initialize(options = {})
    end

    def opsworks_client
      @opsworks_client ||= AWS.ops_works.client
    end

    def stacks
      @stacks ||= opsworks_client.describe_stacks.data.fetch(:stacks, {})
    end

    def instances(stack_id)
      keys = [:hostname, :public_dns, :public_ip]
      opsworks_client.describe_instances(stack_id: stack_id).data.fetch(:instances, {}).map{|h| h.select{|k,v| keys.include? k}}
    end

    def latest_deployment(stack_id)
      keys = [:completed_at, :duration, :iam_user_arn, :command, :status, :custom_json]
      opsworks_client.describe_deployments(stack_id: stack_id).data.fetch(:deployments, {}).first.select{|k,v| keys.include? k}
    end

    def status
      info = {}
      stacks.each do |stack|
        info[stack[:name]]             = {}
        info[stack[:name]][:deploy]    = latest_deployment(stack[:stack_id])
        info[stack[:name]][:instances] = instances(stack[:stack_id])
      end
      pp info
    end

  end
end
