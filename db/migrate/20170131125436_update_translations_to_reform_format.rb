# frozen_string_literal: true
class UpdateTranslationsToReformFormat < ActiveRecord::Migration
  def up
    Translation.where('key ilike ?', 'activerecord.attributes.user.buyer_properties.').each do |t|
      Translation.where(key: 'activemodel.attributes.user/buyer_profile/properties.', instance_id: t.instance_id, locale: t.locale).first_or_create!(value: t.value)
    end

    Translation.where('key ilike ?', 'activerecord.attributes.user.seller_properties.').each do |t|
      Translation.where(key: 'activemodel.attributes.user/seller_profile/properties.', instance_id: t.instance_id, locale: t.locale).first_or_create!(value: t.value)
    end
  end

  def down
  end
end
