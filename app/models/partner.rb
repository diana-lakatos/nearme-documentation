class Partner < ActiveRecord::Base

  attr_accessible :name, :instance_id, :domain_attributes, :theme_attributes
  belongs_to :instance
  has_one :domain, :as => :target, :dependent => :destroy
  has_one :theme, :as => :owner, :dependent => :destroy

  accepts_nested_attributes_for :domain
  accepts_nested_attributes_for :theme, reject_if: proc { |params| params[:name].blank? }

  validates_presence_of :name, :instance_id

  # we overwrite this method to fallback to instance's theme
  def theme
    super.presence || get_or_build_theme_from_instance
  end

  def has_theme?
    self.persisted? && theme.owner_type == 'Partner'
  end

  # we want to give user a chance to easily customize some of the attributes, so we just copy them from instance
  # if object is created, user had his chance
  def get_or_build_theme_from_instance
    self.new_record? ? build_theme_from_instance : instance.theme
  end

  def build_theme_from_instance
    theme_attributes = instance.try(:theme).try(:attributes) || {}
    theme = build_theme
    if theme_attributes
      ['id', 'name', 'compiled_stylesheet', 'owner_id', 'owner_type', 'created_at', 'updated_at'].each do |forbidden_attribute|
        theme_attributes.delete(forbidden_attribute)
      end
      theme_attributes.keys.each do |attribute|
        if attribute.include?('_image')
          url = instance.theme.send("#{attribute}_url")
          if url[0] == "/"
            Rails.logger.debug "local file storage not supported"
          else
            theme.send("remote_#{attribute}_url=", url)
          end if url
          theme_attributes.delete(attribute)
        end
      end

      theme.attributes = theme_attributes
      theme
    end

  end

  def white_label_enabled?
    true
  end
end

