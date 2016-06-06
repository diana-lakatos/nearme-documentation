require_relative 'r53/lib/load_balancer.rb'
require_relative 'r53/lib/hosted_zone.rb'
require_relative 'commands.rb'

module NearMe
  class Balancer
    attr_accessor :certificate_body, :name, :private_key,
                  :certificate_chain, :stack_id, :dns_name,
                  :template_name

    attr_accessor :certificate

    def initialize(options = {})
      @name = options[:name]

      @certificate_body = options[:certificate_body]
      @private_key = options[:private_key]
      @certificate_chain = options[:certificate_chain]

      @template_name = options[:template_name] || 'production'
    end

    def create!
      upload_certificate
      create_balancer
      configure_health_check
      attach_instances
    end

    def update_certificates!
      upload_certificate
      update_load_balancer
    end

    def delete!
      DeleteELBCommand.new(elb_name).execute
      # delete_certificates
      DeleteHostedZoneCommand.new(name).execute
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
    rescue Aws::ElasticLoadBalancing::Errors::CertificateNotFound
      sleep 3
      retry
    end

    def update_load_balancer
      balancer.set_ssl_certificate certificate
    rescue Aws::ElasticLoadBalancing::Errors::CertificateNotFound
      sleep 3
      retry
    end

    def upload_certificate
      @certificate ||= SSLCertificateRepository.upload(
        certificate_name,
        certificate_body,
        private_key,
        certificate_chain)
    end

    def template_balancer
      @template ||= LoadBalancerRepository.find_by_name @template_name
    end
  end
end
