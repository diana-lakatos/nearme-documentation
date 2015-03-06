class ChangeNamesOfTransactableTypes < ActiveRecord::Migration
  def up

    TransactableType.all.each do |tt|
      PlatformContext.current = PlatformContext.new(tt.instance)
      if ["Buy/Sell", "Listing"].include? tt.name
        tt.update_attribute :name, tt.bookable_noun.presence || tt.instance.bookable_noun
      end
    end
  end

  def down
  end
end
