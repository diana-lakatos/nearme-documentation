class Domain < ActiveRecord::Base
  attr_accessible :name, :target, :target_id, :target_type

  belongs_to :target, :polymorphic => true

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :target_type

  DEFAULT_DOMAIN_NAME = 'desksnear.me'
  def self.find_for_request(request)
    host = request.host.gsub(/^www\./, "")
    where(:name => host).first.presence || self.default_domain
  end

  def white_label_company?
    "Company" == target_type
  end

  def instance?
    "Instance" == target_type
  end

  def self.default_domain
    @default_domain ||= self.find_by_name(DEFAULT_DOMAIN_NAME)
  end

end
