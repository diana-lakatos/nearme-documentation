class CreateElbJob < AbstractElbJob
  def perform
    return true if Rails.env.development?

    balancer.create!
    @domain.elb_created!
    @domain.update_column(:dns_name, balancer.dns_name)
  rescue
    @domain.error!
    @domain.update_column(:error_message, $!.message)
  end
end
