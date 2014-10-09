class AddInstanceProfileTypeForEachInstance < ActiveRecord::Migration

  class InstanceProfileType < ActiveRecord::Base
    belongs_to :instance
  end

  class Instance < ActiveRecord::Base
    has_many :instance_profile_types
  end

  def up
    Instance.find_each do |i|
      if i.instance_profile_types.count.zero?
        InstanceProfileType.create(name: 'Instance Profile Type', instance_id: i.id)
      end
    end
  end

  def down
  end

end
