# frozen_string_literal: true
class ChangeLabelForTitleImageOnIntel < ActiveRecord::Migration
  def up
    Instance.transaction do
      Instances::InstanceFinder.get(:devmesh).each do |i|
        i.set_context!

        TransactableType.where(name: 'Project').each do |tt|
          tt.custom_attributes.find_by(name: 'cover_photo').update_attribute(:label, 'Title image')
        end
      end
    end
  end

  def down
  end
end
