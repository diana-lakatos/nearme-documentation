# frozen_string_literal: true
class HelpContent < ActiveRecord::Base
  validates :slug, presence: true, uniqueness: true

  def self.find_by_slug(slug)
    find_by(slug: slug)
  end
end
