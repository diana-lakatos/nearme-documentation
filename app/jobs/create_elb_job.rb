class CreateElbJob < Job
  def after_initialize(domain, certificate_body, private_key, certificate_chain)
    @domain = domain
    @certificate_body = certificate_body
    @private_key = private_key
    @certificate_chain = certificate_chain
  end

  def perform
    b = NearMe::Balancer.new(certificate_body: @certificate_body,
                             name: @domain.to_dns_name,
                             private_key: @private_key,
                             certificate_key: @certificate_chain)
    begin
      b.create!
      @domain.elb_created!
      @domain.update_column(:dns_name, b.dns_name)
    rescue
      @domain.update_column(:error_message, b.errors.join("\n"))
      @domain.error!
      raise $!
    end
  end
end
