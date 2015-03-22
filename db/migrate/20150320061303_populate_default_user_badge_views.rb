class PopulateDefaultUserBadgeViews < ActiveRecord::Migration
  def up
    Instance.where(user_based_marketplace_views: true).each do |i|
      puts "#{i.name} is user based marketplace, populating default liquid views:"
      iv = InstanceView.where(instance_id: i.id, transactable_type_id: nil, path: 'registrations/profile/user_badge', locale: 'en', partial: true, view_type: 'view', format: 'html', handler: 'liquid').first_or_initialize do |iv|
        iv.body = File.read(File.join(Rails.root, 'app', 'views', "#{DbViewResolver.virtual_path('registrations/profile/user_badge', true)}.html.liquid"))
      end
      if iv.new_record?
        iv.save!
        puts "Created registrations/profile/user_badge"
      end
    end
  end

  def down
  end
end
