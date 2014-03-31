class Domain < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  attr_accessible :name, :target, :target_id, :target_type

  belongs_to :target, :polymorphic => true

  before_validation lambda { self.name = self.name.try(:strip) }

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 50
  validates :name, domain_name: true

  validates_presence_of :target_type
  validates_each :name do |record, attr, value|
    if value =~ /^(www\.)?desksnear\.me$/i
      record.errors[:name] << "This domain is not available."
    end
  end

  scope :secured, -> {where(secured: true)}

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

end
