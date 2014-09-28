Spree::Taxon.class_eval do
  include Spree::Scoper

  scope :for_top_navigation, -> { where(in_top_nav: true).order("#{Spree::Taxon.table_name}.top_nav_position ASC") }
end
