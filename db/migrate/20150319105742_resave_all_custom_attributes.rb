class ResaveAllCustomAttributes < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      CustomAttributes::CustomAttribute.find_each do |ca|
        if ca.target.present?
          ca.save!
        else
          ca.destroy
        end
      end
    end
  end

  def down
  end
end

