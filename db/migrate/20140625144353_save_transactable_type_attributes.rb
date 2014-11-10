class SaveTransactableTypeAttributes < ActiveRecord::Migration
  class TransactableTypeAttribute < ActiveRecord::Base
  end

  def self.up
    TransactableTypeAttribute.find_each do |tta|
      next if tta.transactable_type.nil?
      tta.save!
    end
  end

  def self.down

  end
end
