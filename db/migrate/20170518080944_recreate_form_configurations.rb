class RecreateFormConfigurations < ActiveRecord::Migration
  def up
    Instance.all
            .select { |instance| CustomAttributes::CustomAttribute.where(instance_id: instance.id).uploadable.any? }
            .each { |instance| FormComponentToFormConfiguration.new(instance).go! }
  end

  def down
  end
end
