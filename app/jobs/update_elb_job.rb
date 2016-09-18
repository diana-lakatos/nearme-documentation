class UpdateElbJob < AbstractElbJob
  def perform
    return true if Rails.env.development?

    balancer.update_certificates!
    @domain.elb_updated!
  rescue
    @domain.update_column(:error_message, $!.message)
    @domain.failed!
  end
end
