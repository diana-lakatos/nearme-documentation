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
                                       certificate_chain: @certificate_chain,
                                       template_name: template_name
                                      )
  end

  def template_name
    ['production','staging'].find(-> {'staging'}) {|e| e == ENV['RAILS_ENV']}
  end
end
