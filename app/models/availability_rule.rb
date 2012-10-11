class AvailabilityRule < ActiveRecord::Base
  attr_accessible :close_hour, :close_minute, :day, :open_hour, :open_minute

  # === Associations
  belongs_to :target, :polymorphic => true

  # === Validations
  validates :day, :inclusion => 0..6
  validates :open_hour, :inclusion => 0..23
  validates :close_hour, :inclusion => 0..23
  validates :open_minute, :inclusion => 0..59
  validates :close_minute, :inclusion => 0..59

  # === Callbacks
  before_validation :apply_default_minutes

  # Predefined availability templates
  TEMPLATES = [
    Template.new(:id => 'M-F9-5', :name => "Working Week", :days => 0..4, :hours => 9..17),
    Template.new(:id => 'M-F8-6', :name => "Extended Week", :days => 0..4, :hours => 8..18),
    Template.new(:id => 'M-S9-5', :name => "Working Week +1", :days => 0..5, :hours => 9..17)
  ]

  # Return a list of predefined availability rule templates
  def self.templates
    TEMPLATES
  end

  # Returns whether or not this availability rule is 'open' at a given hour & minute
  def open_at?(hour, minute)
    after_opening = hour > open_hour || open_hour == hour && minute >= open_minute
    before_closing = hour < close_hour || close_hour == hour && minute < close_minute
    after_opening && before_closing
  end

  private

  def apply_default_minutes
    self.open_minute ||= 0
    self.close_minute ||= 0
  end
end
