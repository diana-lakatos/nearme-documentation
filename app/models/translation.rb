class Translation < ActiveRecord::Base

  CUSTOM_PREFIX = 'instance_custom'

  belongs_to :instance

  scope :defaults_for, lambda { |locale| where('locale = ? AND instance_id IS NULL', locale) }
  scope :for_instance, lambda { |instance_id| where('instance_id = ?', instance_id) }
  scope :defaults, -> { where('instance_id is null') }
  scope :updated_after, lambda { |updated_at| where('updated_at > ?', updated_at.to_time) }

  validates :key, presence: true, on: :instance_admin
  validates :value, presence: true, on: :instance_admin
  validate :key_format, on: :instance_admin
  validate :key_uniqueness, on: :instance_admin

  def self.custom_defaults
    where('key LIKE ? AND locale = ?', "#{CUSTOM_PREFIX}.%", 'en')
  end

  def prepend_custom_label
    self.key = "#{CUSTOM_PREFIX}.#{key.downcase}"
  end

  private

  def key_uniqueness
    if self.class.where(instance_id: instance_id, key: "#{CUSTOM_PREFIX}.#{key.downcase}").count > 0
      errors.add :key, 'already exists'
    end
  end

  def key_format
    if key.match /[!@#$%^&*()\-+:\/'";,?}{\[\]\\<>\|=±`~§]|\s|\d/
      errors.add :key, 'Unsupported format. Valid format: this.is.my_custom_key'
    end
  end
end
