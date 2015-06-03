class AddI18nLocaleToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :platform_context_detail_type, :string
    add_column :delayed_jobs, :platform_context_detail_id, :integer
    add_column :delayed_jobs, :i18n_locale, :string, limit: 2
    add_index :delayed_jobs, [:platform_context_detail_id, :platform_context_detail_type], name: 'index_delayed_jobs_on_platform_context_detail'
  end
end
