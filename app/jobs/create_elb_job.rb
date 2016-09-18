class CreateElbJob < AbstractElbJob
  def perform
    return true if Rails.env.development?

    @domain.prepare_elb!

    balancer.create!
    @domain.update_column(:dns_name, balancer.dns_name)
    @domain.elb_created!
  rescue
    @domain.update_column(:error_message, $!.message)
    @domain.failed!
  end
end
