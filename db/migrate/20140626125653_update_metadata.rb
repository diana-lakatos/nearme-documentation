class UpdateMetadata < ActiveRecord::Migration

  def up
    TransactableType.find_each do |tp|
      PlatformContext.current = PlatformContext.new(tp.instance)
      tp.transactables.find_each(&:populate_photos_metadata!)
    end
  end

  def down
  end
end
