class AddLocalizationNinjaLanguagesAsCommonValues < ActiveRecord::Migration
  def up
    InstanceView.where(path: 'listings/show', instance_id: 175).each do |view|
      view.update_attributes!(body: view.body.gsub('service_type.ninja.languages.', 'transactable_type.ninja.languages.'))
    end

    InstanceView.where(path: 'listings/show').where.not(instance_id: 175).each do |view|
      view.update_attributes!(body: view.body.gsub('service_type.ninja.languages.', 'service_type.common.languages.'))
    end
  end

  def down; end
end
