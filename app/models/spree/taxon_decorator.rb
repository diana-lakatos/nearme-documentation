Spree::Taxon.class_eval do
  include Spree::Scoper

  scope :for_top_navigation, -> { where(in_top_nav: true).order("#{Spree::Taxon.table_name}.top_nav_position ASC") }

  def name_with_top_nav_position
    result = name
    result += " (in top navigation at position #{top_nav_position})" if in_top_nav?
    result
  end
end
