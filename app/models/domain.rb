class Domain < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  # attr_accessible :name, :target, :target_id, :target_type, :secured

  belongs_to :target, :polymorphic => true

  before_validation lambda { self.name = self.name.try(:strip) }

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :deleted_at
  validates_length_of :name, :maximum => 50
  validates :name, domain_name: true

  before_destroy :prevent_destroy_if_only_child

  validates_presence_of :target_type
  validates_each :name do |record, attr, value|
    if value =~ /^(www\.)?desksnear\.me$/i
      record.errors[:name] << "This domain is not available."
    end
  end

  scope :secured, -> { where(secured: true) }

  delegate :white_label_enabled?, :to => :target

  def url
    secured? ? "https://" + name : "http://" + name
  end

  def white_label_company?
    "Company" == target_type
  end

  def instance?
    "Instance" == target_type
  end

  def partner?
    "Partner" == target_type
  end

  def near_me_domain?
    name =~ /^(.*)\.near-me\.com$/
  end

  private

  def prevent_destroy_if_only_child
    errors.add(:name, "You won't be able to access admin if you delete your only domain") if near_me_domain?
    errors.blank?
  end

end
