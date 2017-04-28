require_relative 'r53/lib/load_balancer.rb'
require_relative 'r53/lib/hosted_zone.rb'

module NearMe
  class Balancer
    attr_accessor :name, :stack_id, :dns_name, :template_name
    attr_accessor :certificate

    def initialize(options = {})
      @name = options[:name]
      @certificate = options[:certificate]
      @template_name = options[:template_name] || 'production'
    end

    def create!
      create_balancer
      configure_health_check
      attach_instances
    end

    def update_certificates!
      update_load_balancer
    end

    def delete!
      LoadBalancerRepository.delete(@name)
      HostedZoneRepository.get_by_name(@name).tap do |zone|
        zone.delete if zone.id
      end
    end

    def dns_name
      balancer.dns_name
    end

    private

    def elb_name
      name.tr('.', '-')
    end

    # generate unique name
    def certificate_name
      [elb_name, Time.now.to_i].join('--')
    end

    def balancer
      @balancer ||= LoadBalancerRepository.find_by_name elb_name
    end

    def attach_instances
      balancer.add_instances template_balancer.instances
    end

    def configure_health_check
      balancer.configure_health_check(template_balancer)
    end

    def create_balancer
      LoadBalancerRepository.create elb_name, template_balancer, certificate
    end

    def update_load_balancer
      balancer.update_ssl_certificate certificate
    end

    def template_balancer
      @template ||= LoadBalancerRepository.find_by_name @template_name
    end
  end
end
