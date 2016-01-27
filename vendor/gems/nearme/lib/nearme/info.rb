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
      deployment = opsworks_client.describe_deployments(stack_id: stack_id).data.fetch(:deployments, {}).first
      deployment ? deployment.select{|k,v| keys.include? k} : "no deploys yet"
    end

    def status
      info = {}
      quick_view = []
      stacks.each do |stack|
        info[stack[:name]]             = {}
        info[stack[:name]][:deploy]    = latest_deployment(stack[:stack_id])
        info[stack[:name]][:instances] = instances(stack[:stack_id])
        results = opsworks_client.describe_instances(stack_id: stack[:stack_id]).data.fetch(:instances, {})
        results.each_with_index do |r, index|
          quick_view << "alias ssh_#{stack[:name].sub(/nm-qa-\d/, '').sub('nm-', '')}#{r[:hostname].gsub('rails-qa-1', 'qa').gsub('rails-qa-', 'qa').gsub('rails-app1', '').gsub('rails-app-1', '').gsub('rails-app-', '').gsub('rails-app', '')}='ssh #{ENV['AWS_USER']}@#{r[:public_ip]}'".gsub('productionutility1', 'utility') unless r[:public_ip].nil? || r[:public_ip].empty?
        end
      end
      pp info
      puts quick_view.join("\n")
    end

  end
end
