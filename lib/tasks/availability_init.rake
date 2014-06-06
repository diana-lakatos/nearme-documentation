desc "Create default availability templates"
task :init_availability => :environment do
  # ZOMG
  gem 'factory_girl_rails'
  require 'factory_girl'
  FactoryGirl.reload

  Instance.all.each do |instance|
    PlatformContext.current = PlatformContext.new(instance)
    FactoryGirl.create(:availability_template, transactable_type: TransactableType.first)
  end
end
