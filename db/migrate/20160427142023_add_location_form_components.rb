class AddLocationFormComponents < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!
      Utils::FormComponentsCreator.new(instance).create!
    end
  end

  def down
  end
end
