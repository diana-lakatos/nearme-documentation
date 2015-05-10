class SetPriceTypesHstoreValueToInstances < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      i.price_types = '1'
      i.price_slider = '0'
      i.save(validate: false)
    end
  end

  def down
    Instance.find_each do |i|
      i.price_types = '0'
      i.price_slider = '0'
      i.save(validate: false)
    end
  end
end
