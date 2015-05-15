class CreateElbJob < Job
  def after_initialize(domain_id, certificate_body, private_key, certificate_chain)
    @domain = Domain.find(domain_id)
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
    rescue Exception => e
      @domain.update_column(:error_message, e.message)
      @domain.error!
      raise e
    end
  end
end
