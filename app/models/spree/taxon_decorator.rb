Spree::Taxon.class_eval do
  include Spree::Scoper

  before_save :set_permalink
  after_save :update_children_permalink

  scope :for_top_navigation, -> { where(in_top_nav: true).order("#{Spree::Taxon.table_name}.top_nav_position ASC") }

  def name_with_top_nav_position
    result = name
    result += " (in top navigation at position #{top_nav_position})" if in_top_nav?
    result
  end

  def encoded_permalink
    permalink.gsub("/", "%2F")
  end

  def update_children_permalink
    children.each { |c| c.save } if reload.children.any?
  end

  def set_permalink
    if parent.present?
      self.permalink = [parent.permalink, name.to_url].join('/')
    else
      self.permalink = name.to_url
    end
  end
end
