Spree::LineItem.class_eval do
  include Spree::Scoper
  inherits_columns_from_association([:company_id], :order) if ActiveRecord::Base.connection.table_exists?(self.table_name)
end
