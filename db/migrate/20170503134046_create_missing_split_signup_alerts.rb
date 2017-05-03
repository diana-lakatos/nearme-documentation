class CreateMissingSplitSignupAlerts < ActiveRecord::Migration
  def self.up
    Instance.find_each do |instance|
      instance.set_context!

      if instance.split_registration?
        signup_creator = Utils::DefaultAlertsCreator::SignUpCreator.new

        signup_creator.create_guest_welcome_email!
        signup_creator.create_guest_verify_email!
        signup_creator.create_host_welcome_email!
        signup_creator.create_host_verify_email!
      end
    end
  end

  def self.down
  end
end
