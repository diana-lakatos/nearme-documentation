class AddProductTypeToBuySellInstances < ActiveRecord::Migration
  def up
    Instance.all.select(&:buyable?).each do |i|
      puts "Checking if #{i.name} has 0 product types"
      PlatformContext.current = PlatformContext.new(i)
      if i.product_types.count.zero?
        puts "  It has, creating one with name: #{i.bookable_noun}"
        i.product_types.create(name: i.bookable_noun)
      end
    end
  end

  def down
  end
end
