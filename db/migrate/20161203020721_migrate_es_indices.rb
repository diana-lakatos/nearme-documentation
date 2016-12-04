class MigrateEsIndices < ActiveRecord::Migration
  def up
    Rake::Task['elastic:indices:create_all'].invoke('true')
    Rake::Task['elastic:aliases:create_all'].invoke
    Rake::Task['elastic:indices:refresh:all'].invoke
    Rake::Task['elastic:indices:rebuild:all_for_instance'].invoke(175)
    Rake::Task['elastic:indices:remove_unused'].invoke()
  end
end
