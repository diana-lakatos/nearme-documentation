class TextFilter < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :creator, class_name: 'User'
  belongs_to :instance, inverse_of: :text_filters

  validates_presence_of :name, :regexp
  validate :regexp_valid

  after_save :update_instance_cache_key
  after_destroy :update_instance_cache_key

  def regexp_valid
    Regexp.new(regexp)
  rescue => e
    errors.add(:regexp, e.to_s)
  end

  def update_instance_cache_key
    instance.recalculate_cache_key!
  end

end

