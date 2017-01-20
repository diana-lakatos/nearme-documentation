class Translation < ActiveRecord::Base
  belongs_to :instance

  scope :defaults_for, ->(locale) { where('locale = ? AND instance_id IS NULL', locale) }
  scope :for_instance, ->(instance_id) { where('instance_id = ?', instance_id) }
  scope :defaults, -> { where('instance_id is null') }
  scope :updated_after, ->(updated_at) { where('updated_at > ?', updated_at.to_time) }
  # Ordering by instance_id DESC is important for when iterating the list because we want the first
  # one in the list to be the default
  # We use where(locale: ['en', locale]) because we only create the default ones for en
  scope :default_and_custom_translations_for_instance, -> (instance_id, locale) { where(locale: ['en', locale]).where('instance_id IS NULL OR instance_id = ?', instance_id).order('key ASC, instance_id DESC') }

  validates :key, presence: true,
                  uniqueness: { scope: [:instance_id, :locale], case_sensitive: false },
                  on: :instance_admin
  validates :value, presence: true, on: :instance_admin
  validate :key_format, on: :instance_admin

  include Cacheable

  def key_format
    if key.match /[!@#$%^&*()\+:'";,?}{\[\]\\<>\|=±`~§]|\s/
      errors.add :key, 'Unsupported format. Valid format: this.is.my_custom_key'
    end
  end
end
