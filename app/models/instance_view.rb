class InstanceView < ActiveRecord::Base
  has_paper_trail
  belongs_to :instance_type
  belongs_to :instance
  # attr_accessible :body, :path, :format, :handler, :locale, :partial
  scope :for_instance_id, ->(instance_id) {
    where('instance_id IS NULL OR instance_id = ?', instance_id)
  }
  scope :for_instance_type_id, ->(instance_type_id) {
    where('instance_type_id IS NULL OR instance_type_id = ?', instance_type_id)
  }

  validates_presence_of :body
  validates_presence_of :path
  validates_inclusion_of :locale, in: I18n.available_locales.map(&:to_s)
  validates_inclusion_of :handler, in: ActionView::Template::Handlers.extensions.map(&:to_s)
  validates_inclusion_of :format, in: Mime::SET.symbols.map(&:to_s)

  before_validation do
    self.locale ||= 'en'
  end

end
