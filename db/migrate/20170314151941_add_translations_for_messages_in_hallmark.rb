# frozen_string_literal: true
class AddTranslationsForMessagesInHallmark < ActiveRecord::Migration
  def up
    Instance.transaction do
      hallmark_id = 5011
      Instance.where(id: [hallmark_id]).each do |i|
        i.set_context!

        ts = [
          { key: 'messages.trigger_button', value: 'Message' },
          { key: 'activity_feed.verbs.unfollow', value: 'Following' }
        ]

        ts.each do |t|
          i.translations.where(
            locale: 'en',
            key: t[:key]
          ).first_or_initialize.update!(value: t[:value])
        end
      end
    end
  end

  def down
  end
end
