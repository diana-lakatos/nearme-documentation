class AbstractElbJob < Job
  def after_initialize(domain_id)
    @domain = Domain.find(domain_id)
  end

  private

  def balancer
    @balancer ||= NearMe::Balancer.new(
      name: @domain.load_balancer_name,
      certificate: @domain.aws_certificate
    )
  end

  def template_name
    ['production', 'staging'].find(-> {'staging'}) {|e| e == ENV['RAILS_ENV']}
  end
end
