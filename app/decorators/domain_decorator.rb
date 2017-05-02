class DomainDecorator < Draper::Decorator
  delegate_all

  def hosted_zone
    @hosted_zone ||= HostedZoneRepository.get_by_name(name)
  end

  def balancer
    @balancer ||= LoadBalancerRepository.find_by_name(load_balancer_name)
  end
end
