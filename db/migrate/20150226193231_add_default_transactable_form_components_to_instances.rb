class AddDefaultTransactableFormComponentsToInstances < ActiveRecord::Migration
  def self.up
    Instance.all.each do |instance|
      PlatformContext.current = PlatformContext.new(instance)
      instance.transactable_types.each do |transactable_type|
        Utils::FormComponentsCreator.new(transactable_type, 'transactable').create!
      end
    end
  end

  def self.down
  end
end
