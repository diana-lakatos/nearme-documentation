# frozen_string_literal: true
# AWS Route 53 Hosted Zone Resource Record
class ResourceRecordForm < Form
  attr_accessor :type, :name, :hosted_zone_name, :hosted_zone_id, :value, :ttl, :balancer

  validates :hosted_zone_name, :type, :value, presence: true

  def process
    return unless valid?

    if type == 'ALIAS'
      add_alias
    else
      add_record
    end

  rescue Aws::Route53::Errors::ServiceError
    errors.add :base, $ERROR_INFO.to_s
    false
  end

  def dns_name
    [name, hosted_zone_name]
      .reject(&:blank?)
      .join('.')
  end

  def record
    {
      name: dns_name,
      type: type,
      ttl: ttl,
      resource_records: resource_records_values
    }
  end

  def resource_records_values
    value
      .split("\n")
      .map { |line| { value: escape_value(line) } }
  end

  def escape_value(value)
    return value unless type == 'TXT'

    "\"#{value}\""
  end

  def hosted_zone
    HostedZoneRepository.get_by_name(hosted_zone_name)
  end

  def add_record
    ResourceRecordRepository.add_record hosted_zone, record
  end

  def add_alias
    ResourceRecordRepository.add_alias_record_to_target hosted_zone, balancer
  end
end
