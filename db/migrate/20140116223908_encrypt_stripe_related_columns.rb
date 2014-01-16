class EncryptStripeRelatedColumns < ActiveRecord::Migration

  def up
    add_column :users, :encrypted_stripe_id, :string
    add_column :users, :encrypted_paypal_id, :string
    add_column :instances, :encrypted_stripe_api_key, :string

    # existing values encrypt and drop unencrypted columns.
    # the trick is that gem automagically takes care of populating encrypted value
    # so we just need to take care of clearing old one
    User.where('paypal_id is not null OR stripe_id is not null').all.each do |user|
      if user.read_attribute(:stripe_id).present?
        user.stripe_id = user.read_attribute(:stripe_id)
        user.send(:write_attribute, :stripe_id, nil)
      end
      if user.read_attribute(:paypal_id).present?
        user.paypal_id = user.read_attribute(:paypal_id)
        user.send(:write_attribute, :paypal_id, nil)
      end
      user.save(validate: false)
    end

    Instance.where('stripe_api_key is not null').all.each do |instance|
      instance.stripe_api_key =  instance.read_attribute(:stripe_api_key)
      instance.send(:write_attribute, :stripe_api_key, nil)
      instance.save(validate: false)
    end
  end

  def down
    User.where('encrypted_paypal_id is not null OR encrypted_stripe_id is not null').find_each do |user|
      if user.stripe_id.present?
        user.update_column(:stripe_id, user.stripe_id)
      end

      if user.paypal_id.present?
        user.update_column(:paypal_id, user.paypal_id)
      end
    end

    Instance.where('encrypted_stripe_api_key is not null').find_each do |instance|
      instance.update_column(:stripe_api_key, user.stripe_api_key)
    end

    remove_column :users, :encrypted_stripe_id
    remove_column :users, :encrypted_paypal_id
    remove_column :instances, :encrypted_stripe_api_key
  end
end
