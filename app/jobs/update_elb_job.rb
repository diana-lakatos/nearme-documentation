class UpdateElbJob < Job
  def after_initialize(domain, certificate_body, private_key, certificate_chain)
    @domain = domain
    @certificate_body = certificate_body
    @private_key = private_key
    @certificate_chain = certificate_chain
  end

  def perform
    begin
      b = NearMe::Balancer.new(certificate_body: @certificate_body,
                             name: @domain.to_dns_name,
                             private_key: @private_key,
                             certificate_key: @certificate_chain)

      b.update_certificates!

      @domain.elb_updated!
    rescue Exception => e
      @domain.error_update!
      @domain.update_column(:error_message, e.message)
      raise e
    end
  end
end
