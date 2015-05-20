class CreateProfileFormComponents < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!
      instance.instance_profile_types.find_each do |ipt|
        Utils::FormComponentsCreator.new(ipt).create!
      end
    end
  end

  def down
  end
end
