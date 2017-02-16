class HostedZone
  extend Forwardable

  def_delegators :@resource, :id, :name, :resource_record_set_count

  def initialize(resource)
    @resource = resource
  end

  # target: ELB S3 EC2
  def add_target(target)
    ResourceRecordRepository.add_alias_record_to_target self, target
  end

  def records
    ResourceRecordRepository.all(self)
  end

  def name_servers
    records.find { |record| record.type == 'NS' }
  end

  def delete
    HostedZoneRepository.delete id
  end

  def present?
    id.present?
  end
end

module HostedZoneRepository

  def self.find_by_name(name)
    HostedZone.new(find_one_by_name(name))
  end

  # TODO: can search using sdk?
  def self.find_one_by_name(name)
    all.find(-> { Aws::Route53::Types::HostedZone.new }) do |zone|
      name && zone.name =~ /\A#{name}\.\Z/
    end
  end

  def self.all
    client.list_hosted_zones.hosted_zones
  end

  def self.create(name, caller_reference = "caller-reference-#{name}-#{Time.now.to_i}")
    client.create_hosted_zone name: name, caller_reference: caller_reference
  end

  def self.delete(zone_id)
    client.delete_hosted_zone id: zone_id
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

  def self.add_record(zone, record)
    {
      hosted_zone_id: zone.id,
      change_batch: {
        changes: [
          {
            action: 'CREATE',
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

module ResourceRecordDecorator
  def id
    [name.gsub('.','_'), type].join('-')
  end
end

class ResourceRecordRepository
  TYPE = ['A', 'ALIAS', 'CNAME', 'MX', 'TXT', 'SPF']

  def self.find_by_zone_and_name_and_type(zone, name, type)
    zone.records.find { |record| record.name == name && record.type == type }
  end

  def self.add_record(zone, record)
    apply_change ChangeRecordBuilder.add_record(zone, record)
  end

  def self.delete_resource_record(zone, record)
    apply_change ChangeRecordBuilder.delete_record(zone, record)
  end

  def self.add_alias_record_to_target(zone, target)
    apply_change ChangeRecordBuilder.add_alias_record(zone, target)
  end

  private

  def self.apply_change(change)
    client.change_resource_record_sets change
  end

  def self.client
    Aws::Route53::Client.new
  end

  def self.all(zone)
    client
      .list_resource_record_sets(hosted_zone_id: zone.id)
      .resource_record_sets
      .map { |record| record.extend(ResourceRecordDecorator) }
  end
end
