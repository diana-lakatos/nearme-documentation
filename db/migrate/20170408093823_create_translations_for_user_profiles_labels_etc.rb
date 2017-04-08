# frozen_string_literal: true
class CreateTranslationsForUserProfilesLabelsEtc < ActiveRecord::Migration
  def up
    PlatformContext.current = nil
    Translation.where('key ilike ? AND key ilike ?', 'simple_form.%', '%buyer_profile%').find_each do |t|
      Translation.create!(
        key: t.key.sub('.buyer_profile.', '.buyer.'),
        value: t.value,
        locale: t.locale,
        instance_id: t.instance_id
      )
    end
    Translation.where('key ilike ? AND key ilike ?', 'simple_form.%', '%seller_profile%').find_each do |t|
      Translation.create!(
        key: t.key.sub('.seller_profile.', '.seller.'),
        value: t.value,
        locale: t.locale,
        instance_id: t.instance_id
      )
    end
    Translation.where('key ilike ?', '%user/buyer_profile%%').find_each do |t|
      Translation.create!(
        key: t.key.sub('user/buyer_profile', 'user/profiles/buyer'),
        value: t.value,
        locale: t.locale,
        instance_id: t.instance_id
      )
    end
    Translation.where('key ilike ?', '%user/seller_profile%%').find_each do |t|
      Translation.create!(
        key: t.key.sub('user/seller_profile', 'user/profiles/seller'),
        value: t.value,
        locale: t.locale,
        instance_id: t.instance_id
      )
    end
  end

  def down
  end
end
