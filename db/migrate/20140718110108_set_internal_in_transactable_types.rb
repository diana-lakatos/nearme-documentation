class SetInternalInTransactableTypes < ActiveRecord::Migration

  class TransactableTypeAttribute < ActiveRecord::Base
  end

  def up
    TransactableTypeAttribute.where(name: ['rank', 'availability_rules_text', 'external_id', 'delta', 'last_request_photos_sent_at']).update_all(internal: true, public: false)
    TransactableTypeAttribute.where(name: ['daily_price_cents', 'weekly_price_cents', 'monthly_price_cents', 'hourly_price_cents']).update_all(internal: true, public: true)
    if TransactableTypeAttribute.where(name: 'url', instance_id: 18, transactable_type_id: 8).count.zero?
      @tta = TransactableTypeAttribute.new(name: 'url', transactable_type_id: 8, attribute_type: 'string', html_tag: 'input', public: true, internal: false )
      @tta.instance_id = 18
      @tta.save!
    end
  end

  def down

  end
end
