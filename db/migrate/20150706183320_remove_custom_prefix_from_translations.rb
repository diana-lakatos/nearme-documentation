class RemoveCustomPrefixFromTranslations < ActiveRecord::Migration
  def up
    Translation.unscoped.where.not(instance_id: nil).
      where("key ILIKE 'instance_custom.%'").
      update_all("key = replace(key, 'instance_custom.', '')")
  end
end
