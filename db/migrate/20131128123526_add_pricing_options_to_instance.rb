class AddPricingOptionsToInstance < ActiveRecord::Migration

  class Instance < ActiveRecord::Base
    PRICING_OPTIONS = %w(free hourly daily weekly monthly)
  end

  def up
    add_column :instances, :pricing_options, :text

    Instance.all.each do |instance|
      instance.pricing_options = Hash[Instance::PRICING_OPTIONS.map{|po| [po, '1']}] 
      instance.save!
    end
  end

  def down
    remove_column :instances, :pricing_options
  end
end
