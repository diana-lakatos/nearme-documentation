class PopulateDimensionsTemplateColumns < ActiveRecord::Migration
  class Delivery < ActiveRecord::Base
    belongs_to :order, inverse_of: :deliveries
  end

  class TransactableDimensionsTemplate < ActiveRecord::Base
    belongs_to :dimensions_template
  end

  def up
    Delivery.find_each do |d|
      if d.order&.transactable&.dimensions_template&.id
        puts "Updating delivery #{d.id}"
        d.update_attributes!(dimensions_template_id: d.order.transactable.dimensions_template.id)
      else
        puts "Deleting delivery #{d.id}"
      end
    end
    TransactableDimensionsTemplate.reset_column_information
    TransactableDimensionsTemplate.find_each do |td|
      td.update_attributes! instance_id: td.dimensions_template.instance_id
    end
  end

  def down
  end
end
