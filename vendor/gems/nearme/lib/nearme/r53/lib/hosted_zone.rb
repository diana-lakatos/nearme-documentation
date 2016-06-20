class HostedZone
  extend Forwardable

  def_delegators :@resource, :id, :name

  def initialize(resource)
    @resource = resource
  end

  # target: ELB S3 EC2
  def add_target(target)
    HostedZoneRepository.add_target self, target
  end

  def records
    HostedZoneRepository.list_resource_record_sets(self).resource_record_sets
  end

  def name_servers
    records.find do |server|
      server.type == 'NS'
    end
  end

  def delete
    HostedZoneRepository.delete self
  end
end

module HostedZoneRepository

  def self.find_by_name(name)
    HostedZone.new(find_one_by_name(name))
  end

  #TODO can search using sdk?
  def self.find_one_by_name(name)
    all.find( -> {Aws::Route53::Types::HostedZone.new}) do |zone|
      name && zone.name =~ /^#{name}/
    end
  end

  def self.all
    client.list_hosted_zones.hosted_zones
  end

  def self.remove(hosted_zone)
    client.delete_hosted_zone hosted_zone_id: hosted_zone.id
  end

  def self.create(name, caller_reference = "caller-reference-#{name}")
    client.create_hosted_zone name: name, caller_reference: caller_reference
  end

  def self.add_target(zone, target)
    apply_change ChangeRecordBuilder.add_alias_record(zone, target)
  end

  def self.delete(zone)
    delete_alias zone

    client.delete_hosted_zone id: zone.id
  end

  def self.delete_alias(zone)
    alias_record = zone.records.find { |record| record.type == 'A' }
    return unless alias_record

    apply_change ChangeRecordBuilder.delete_record(zone, alias_record)
  end

  def self.apply_change(change)
    client.change_resource_record_sets change
  end

  def self.list_resource_record_sets(zone)
    client.list_resource_record_sets hosted_zone_id: zone.id
  end

  def self.client
    Aws::Route53::Client.new
  end
end

class ChangeRecordBuilder
  def self.delete_record(zone, record)
    {
      hosted_zone_id: zone.id,
      change_batch: {
        changes: [
          {
            action: 'DELETE',
            resource_record_set: record
          }
        ]
      }
    }
  end
  def self.add_alias_record(zone, target)
    {
      hosted_zone_id: zone.id,
      change_batch: {
        changes: [
          {
            action: 'CREATE',
            resource_record_set: {
              name: zone.name,
              type: 'A',
              alias_target: {
                hosted_zone_id: target.canonical_hosted_zone_name_id, # ELB S3 EC2
                dns_name: target.canonical_hosted_zone_name,
                evaluate_target_health: false
              }
            }
          }
        ]
      }
    }
  end
end

class CreateRecord
  def self.build(zone, change) #target, name = zone.name)

  end
end

module DeleteRecord
  def self.build(zone, target)
  end
end
