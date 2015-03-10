class FixNameAndBuyableInTransactionTypes < ActiveRecord::Migration
  def change

    TransactableType.unscoped.find_each do |tt|
      columns = { buyable: tt.name == 'Buy/Sell'}
      
      if ["Buy/Sell", "Listing"].include? tt.name
        columns[:name] = tt.bookable_noun.presence || tt.instance.bookable_noun
      end

      p "Updating #{tt.id}##{tt.name} with columns: #{columns}"
      tt.update_columns columns
    end

  end
end
