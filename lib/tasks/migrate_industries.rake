desc 'converts availability rules to new format'
task migrate_industries: :environment do
  user_ids = UserIndustry.pluck(:user_id)
  company_ids = CompanyIndustry.pluck(:company_id)
	instance_ids = User.where(id: user_ids).pluck(:instance_id)
	instance_ids << Company.where(id: company_ids).pluck(:instance_id)

	instance_ids.uniq!

	instance_ids.each do |instance_id|
		Instance.find(instance_id).set_context! rescue next

		category = Category.create(name: "Industries")

		category.project_types << ProjectType.all
		category.transactable_types << ServiceType.all
		category.product_types << Spree::ProductType.all
		category.instance_profile_types << InstanceProfileType.all

		industries = ActiveRecord::Base.connection.execute("SELECT * FROM industries")
		industries.each do |record|
			Category.create(name: record['name'], parent_id: category.id)
		end

		FormComponent.all.each do |form_component|
			form_component.form_fields.each_with_index do |field, idx|
				if field.values.include?("industries")
					key = field.keys.first == :company ? 'transactable' : 'user'
					form_component.form_fields[idx] = { key => "Category - Industries" }
					form_component.save!
				end
			end
		end
	end
end
