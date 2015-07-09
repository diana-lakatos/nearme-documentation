class UpdateElbJob < Job
  def after_initialize(domain_id, certificate_body, private_key, certificate_chain)
    @domain = Domain.find(domain_id)
    @certificate_body = certificate_body
    @private_key = private_key
    @certificate_chain = certificate_chain
  end

  def perform
    begin
      b = NearMe::Balancer.new(certificate_body: @certificate_body,
                             name: @domain.to_dns_name,
                             private_key: @private_key,
                             certificate_chain: @certificate_chain)

      b.update_certificates!

      @domain.elb_updated!
    rescue Exception => e
      @domain.error_update!
      @domain.update_column(:error_message, e.message)
    end
  end
end
