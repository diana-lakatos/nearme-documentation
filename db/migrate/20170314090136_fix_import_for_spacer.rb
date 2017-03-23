class FixImportForSpacer < ActiveRecord::Migration
  def up
    Instances::InstanceFinder.get(:spacer).each do |i|
      i.set_context!

      companies = i.companies.where("external_id NOT ILIKE 'manual-%'")
      companies.find_each do |company|
        company.completed_at = Time.zone.now
        company.save!
      end
      puts "Fixed completed_at for #{companies.count} companies in spacer"
    end
  end

  def down
  end
end
