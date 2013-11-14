class Domain < ActiveRecord::Base
  attr_accessible :name, :target, :target_id, :target_type

  belongs_to :target, :polymorphic => true

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :target_type
  validates_each :name do |record, attr, value|
    if value =~ /^(www\.)?desksnear\.me$/i
      record.errors[:name] << "This domain is not available."
    end
  end

  delegate :white_label_enabled?, :to => :target

  def white_label_company?
    "Company" == target_type
  end

  def instance?
    "Instance" == target_type
  end

  def partner?
    "Partner" == target_type
  end

  def self.is_root_domain?(domain_name)
    root_domains = [Regexp.escape(Rails.application.routes.default_url_options[:host])]
    root_domains += ['test\.host', '127\.0\.0\.1:.*', 'example\.org'] if Rails.env.test?
    domain_name =~ Regexp.new("^(www\.)?(#{root_domains.join('|')})$", true)
  end

end
