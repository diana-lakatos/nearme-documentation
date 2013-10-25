require 'footer_resolver'

class FooterTemplate < ActiveRecord::Base
  belongs_to :theme
  attr_accessible :body, :partial, :path, :handler, :theme_id

  validates :body, :path, :theme_id, presence: true

  after_save do
    FooterResolver.instance.clear_cache
  end

  def locale
    "en"
  end

  def handler
    "liquid"
  end
end
