# frozen_string_literal: true
class AddTranslationsForGalleryAndLinks < ActiveRecord::Migration
  def up
    i = Instance.find_by(id: 5011)
    return true if i.nil?
    i.set_context!

    t = Translation.where(locale: :en, key: 'about_tab.links', instance_id: 5011).first_or_initialize
    t.value = 'Links'
    t.save!

    t = Translation.where(locale: :en, key: 'about_tab.gallery', instance_id: 5011).first_or_initialize
    t.value = 'Gallery'
    t.save!
  end

  def down
  end
end
