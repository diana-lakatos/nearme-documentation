namespace :fixtypo do
  desc "Fixes typo in industries "
  task :industry => :environment do
   wrong_industry = Industry.find_by_name('Atvertising') 
   right_industry = Industry.where(:name => 'Advertising').first_or_create!(:name => 'Advertising')
   CompanyIndustry.update_all("industry_id = #{right_industry.id}", "industry_id = #{wrong_industry.id}")
   UserIndustry.update_all("industry_id = #{right_industry.id}", "industry_id = #{wrong_industry.id}")
  end
end
