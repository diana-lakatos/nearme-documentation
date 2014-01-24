class SetDefaultStripeCredentialsForDnm < ActiveRecord::Migration

  class Instance < ActiveRecord::Base
    attr_encrypted :stripe_api_key, :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

    def self.default_instance
      self.find_by_default_instance(true)
    end
  end

  def up
    dnm_instance = Instance.default_instance

    if dnm_instance
      dnm_instance.stripe_api_key = Rails.env.production? ? 'sk_live_YJet2CBSWgQ2UeuvQiG0vKEC' : 'sk_test_lpr4WQXQdncpXjjX6IJx01W7'
      dnm_instance.stripe_public_key = Rails.env.production? ? 'pk_live_h3zjCFhi02B4c9juuzmFOe3n' : 'pk_test_iCGA8nFZdILrI1UtuMOZD2aq'
      dnm_instance.save!
    end
  end

  def down
  end
end
