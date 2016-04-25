require 'aws'

module NearMe
  class Balancer
    attr_accessor :certificate_body, :name, :private_key, :certificate_chain,
      :stack_id, :dns_name, :template_name

    def initialize(options = {})
      self.certificate_body = options[:certificate_body]
      self.name = options[:name]
      self.private_key = options[:private_key]
      self.certificate_chain = options[:certificate_chain]
      self.stack_id = options[:stack_id]
      self.template_name = options[:template_name] || "production"
    end

    def create!
      begin
        iam.client.delete_server_certificate(server_certificate_name: name)
      rescue AWS::ELB::Errors::CertificateNotFound
      rescue AWS::IAM::Errors::NoSuchEntity
      end

      begin
        certificate = create_certificate
        sleep 5
        balancer = create_balancer(certificate.arn)
        self.dns_name = balancer.dns_name
        # configure health check
        elb.configure_health_check(load_balancer_name: name,
                                   health_check: health_check_params)
        # attach instances
        elb.register_instances_with_load_balancer(load_balancer_name: name, instances: instances)
      rescue Exception => e
        delete!
        raise e
      end
    end

    def delete!
      begin
        iam.client.delete_server_certificate(server_certificate_name: name)
      rescue AWS::ELB::Errors::CertificateNotFound
      rescue AWS::IAM::Errors::NoSuchEntity
      end

      elb.delete_load_balancer(load_balancer_name: name)
    end

    def update_certificates!
      begin
        iam.client.delete_server_certificate(server_certificate_name: name)
      rescue AWS::ELB::Errors::CertificateNotFound
      rescue AWS::IAM::Errors::NoSuchEntity
      end

      sleep 2
      certificate = create_certificate
      sleep 12 # give time for the cert to instantiate on the aws side (i.e. win the race condition)
      # a proper fix for this and the above is in the next release (NM-)2152.

      elb.set_load_balancer_listener_ssl_certificate(load_balancer_name: name, load_balancer_port: 443, ssl_certificate_id: certificate.arn)
    end


    def health_check_params
      template_balancer[:health_check]
    end

    def instances
      template_balancer[:instances]
    end

    def iam
      @iam ||= AWS::IAM.new
    end

    def certificates
      @certificates ||= iam.server_certificates
    end

    def elb
      @elb = AWS::ELB.new.client
    end

    def http_listener
      template_balancer[:listener_descriptions].find{|l| l[:listener][:protocol] == "HTTP"}[:listener]
    end

    def https_listener(certificate_arn)
      template_balancer[:listener_descriptions].find{|l| l[:listener][:protocol] == "HTTPS"}[:listener].merge(ssl_certificate_id: certificate_arn)
    end

    def availability_zones
      template_balancer[:availability_zones]
    end

    def security_groups
      template_balancer[:security_groups]
    end

    def create_balancer(certificate_arn)

      load_balancer = elb.create_load_balancer(load_balancer_name: name,
                                                :availability_zones => availability_zones,
                                                :security_groups => security_groups,
                                                :listeners => [http_listener, https_listener(certificate_arn)])
    end

    def create_certificate
      params = {
        name: name,
        certificate_body: certificate_body,
        certificate_chain: certificate_chain,
        private_key: private_key
      }.select{|k,v| !v.to_s.empty?}

      certificates.create(params)
    end

    def template_balancer
      @template_balancer ||= elb.describe_load_balancers(load_balancer_names: [template_name]).data[:load_balancer_descriptions][0]
    end
  end
end
