class AssignAvailabilityTemplateIfNil < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!
      if instance.availability_templates.first
        ids = Location.all.select{|location| location.availability_template.nil?}.map(&:id)
        Location.where(id: ids).update_all(availability_template_id: instance.availability_templates.first.try(:id))

        transactable_ids = Transactable.where.not(availability_template_id: nil).select{|location| location.availability_template.nil?}.map(&:id)
        Transactable.where(id: transactable_ids).update_all(availability_template_id: instance.availability_templates.first.try(:id))

        p "Updated locations(#{ids.size}) and transactables(#{transactable_ids.size}) for instance #{instance.id} #{instance.name}"
      else
        p "!!! Instance #{instance.id} #{instance.name} has no availability templates !!!"
      end
    end
  end
end
