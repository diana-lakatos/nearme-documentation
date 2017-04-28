class SetupHostedZoneJob < Job
  include Job::HighPriority

  def after_initialize(domain_id)
    @domain = Domain.find(domain_id)
  end

  def perform
    create_hosted_zone
    configure_alias_record
  end

  private

  def create_hosted_zone
    HostedZoneRepository.create @domain.name
  rescue Aws::Route53::Errors::HostedZoneAlreadyExists
    # TODO: capture error but do not stop - raygun?
  end

  def configure_alias_record
    zone.add_target balancer
 rescue Aws::Route53::Errors::InvalidChangeBatch
   # TODO: capture error but do not stop - raygun?
 end

  def zone
    @zone ||= HostedZoneRepository.get_by_name @domain.name
  end

  def balancer
    LoadBalancerRepository.find_by_name(@domain.load_balancer_name).tap do |b|
      fail ArgumentError, "Could not find balancer #{ @domain.load_balancer_name} for domain #{@domain.name}" if b.load_balancer_name.nil?
    end
  end
end
