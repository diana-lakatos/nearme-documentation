class AbstractElbJob < Job
  def after_initialize(domain_id, certificate_body, private_key, certificate_chain)
    @domain = Domain.find(domain_id)
    @certificate_body = certificate_body
    @private_key = private_key
    @certificate_chain = certificate_chain
  end

  private

  def balancer
    @balancer ||= NearMe::Balancer.new(certificate_body: @certificate_body,
                                       name: @domain.load_balancer_name,
                                       private_key: @private_key,
                                       certificate_chain: @certificate_chain)
  end
end
