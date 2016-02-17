class FixCompanies < ActiveRecord::Migration
  def change
    Rake::Task['fix:companies_metadata'].invoke
  end
end
