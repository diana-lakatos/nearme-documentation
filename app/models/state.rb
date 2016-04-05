class State < ActiveRecord::Base

  has_many :tax_rates
  belongs_to :country

  validates :abbr, presence: true
  validates :country, presence: true

  def to_s
    name
  end

  def full_name
    "#{name} (#{abbr})"
  end

end

