class UpdateElbJob < AbstractElbJob
  def perform
    return true if Rails.env.development?

    balancer.update_certificates!
  rescue
    @domain.update_column(:error_message, $!.message)
  end
end
