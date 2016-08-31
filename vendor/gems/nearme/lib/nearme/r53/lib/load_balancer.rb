require 'aws-sdk'
class LoadBalancer
  extend Forwardable

  def_delegators :@resource,
                 :load_balancer_name,
                 :canonical_hosted_zone_name,
                 :canonical_hosted_zone_name_id,
                 :instances,
                 :listener_descriptions,
                 :availability_zones,
                 :health_check,
                 :security_groups,
                 :dns_name

  def initialize(resource)
    @resource = resource
  end

  def add_instances(instances)
    LoadBalancerRepository.add_instances self, instances
  end

  def configure_health_check(template)
    LoadBalancerRepository.configure_health_check self, template.health_check
  end

  def update_ssl_certificate(certificate)
    Aws::ElasticLoadBalancing::Client
      .new
      .set_load_balancer_listener_ssl_certificate load_balancer_name: load_balancer_name,
                                                  load_balancer_port: 443,
                                                  ssl_certificate_id: certificate.arn
  end

  def present?
    load_balancer_name.present?
  end
end

module LoadBalancerRepository
  AWS_STRUCT = Aws::ElasticLoadBalancing::Types::LoadBalancerDescription

  def self.find_by_name(name)
    LoadBalancer.new find_one_by_name(name)
  end

  def self.find_one_by_name(name)
    all.find(-> { AWS_STRUCT.new }) do |item|
      item.load_balancer_name =~ /^#{name}/
    end
  end

  def self.create(name, template, certificate)
    client
      .create_load_balancer load_balancer_name: name,
                            listeners: prepare_listeners(template.listener_descriptions, certificate),
                            availability_zones: template.availability_zones,
                            security_groups: template.security_groups
  end

  def self.prepare_listeners(listeners, certificate)
    listeners.map do |data|
      if data.listener.protocol == 'HTTPS'
        data.listener.ssl_certificate_id = certificate.arn
      end

      data.listener
    end
  end

  def self.all
    client
      .describe_load_balancers # (load_balancer_names: ['linguamag-eu'])
      .load_balancer_descriptions
  end

  def self.add_instances(balancer, instances)
    client
      .register_instances_with_load_balancer instances: instances,
                                             load_balancer_name: balancer.load_balancer_name
  end

  def self.configure_health_check(balancer, health_check)
    client.configure_health_check(
      load_balancer_name: balancer.load_balancer_name,
      health_check: health_check
    )
  end

  def self.delete(load_balancer_name)
    client.delete_load_balancer load_balancer_name: load_balancer_name
  end

  def self.client
    Aws::ElasticLoadBalancing::Client.new
  end
end

class SSLCertificate
  extend Forwardable

  def_delegators :@resource, :server_certificate_id, :arn, :server_certificate_name

  def initialize(resource)
    @resource = resource
  end
end

module SSLCertificateRepository
  def self.find_by_name(name)
    response = find_one_by_name(name)

    SSLCertificate.new response.server_certificate.server_certificate_metadata
  end

  def self.find_one_by_name(name)
    client.get_server_certificate server_certificate_name: name
  end

  def self.upload(certificate_name, certificate_body, private_key, certificate_chain)
    uploaded_certificate = client
                           .upload_server_certificate server_certificate_name: certificate_name,
                                                      certificate_body: certificate_body,
                                                      private_key: private_key,
                                                      certificate_chain: certificate_chain

    SSLCertificate.new uploaded_certificate.server_certificate_metadata
  end

  def self.all
    client.list_server_certificates
  end

  def self.delete(certificate_name)
    client.delete_server_certificate server_certificate_name: certificate_name
  end

  def self.client
    Aws::IAM::Client.new
  end
end
