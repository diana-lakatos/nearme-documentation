class DomainDecorator < Draper::Decorator
  delegate_all

  def hosted_zone
    @hosted_zone ||= HostedZoneRepository.find_by_name(name)
  end

  def balancer
    @balancer ||= LoadBalancerRepository.find_by_name(load_balancer_name)
  end

  def balancer?
    balancer.load_balancer_name
  end

  def hosted_zone?
    hosted_zone && hosted_zone.id
  end

  def name_servers
    hosted_zone.name_servers.resource_records.map(&:value)
  end
end
