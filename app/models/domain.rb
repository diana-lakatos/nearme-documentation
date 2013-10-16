class Domain < ActiveRecord::Base
  attr_accessible :name, :target, :target_id, :target_type

  belongs_to :target, :polymorphic => true

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :target_type
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
