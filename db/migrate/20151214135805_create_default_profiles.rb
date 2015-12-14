class CreateDefaultProfiles < ActiveRecord::Migration
  def up
      Rake::Task['instance_profile:create_default_profile'].invoke
      Rake::Task['instance_profile:create_translations'].invoke
  end

  def down
  end
end
