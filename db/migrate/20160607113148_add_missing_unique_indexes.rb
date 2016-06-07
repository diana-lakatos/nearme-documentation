class AddMissingUniqueIndexes < ActiveRecord::Migration
  class TmpInstanceAdmin < ActiveRecord::Base
    self.table_name = 'instance_admins'
  end

  class TmpReview < ActiveRecord::Base
    self.table_name = 'reviews'
  end

  def change
    add_index :activity_feed_subscriptions, [:follower_id, :followed_identifier], name: :index_subscriptions_on_folllower_and_followed_identifier, unique: true
    add_index :countries, [:iso], unique: true
    add_index :custom_model_types, [:name, :deleted_at, :instance_id], unique: true
    add_index :instance_admin_roles, [:name, :instance_id], unique: true
    add_index :instance_creators, [:email], unique: true
    add_index :location_types, [:name, :instance_id], unique: true
    add_index :pages, [:slug, :theme_id], unique: true, where: '(deleted_at IS NULL)'
    add_index :project_collaborators, [:user_id, :project_id], unique: true, where: '(deleted_at IS NULL)'
    add_index :tax_regions, [:country_id], unique: true
    add_index :workflow_alerts, [:template_path, :workflow_step_id, :recipient_type, :alert_type, :deleted_at], unique: true, name: 'index_workflows_alerts_on_templ_step_recipient_alert_and_del'
    add_index :workflow_steps, [:associated_class, :instance_id, :deleted_at], unique: true, name: 'index_workflow_steps_on_assoc_class_and_instance_and_deleted'
    add_index :custom_attributes, [:name, :target_id, :target_type, :deleted_at], unique: true, name: 'index_custom_attributes_on_name_and_target_and_type_and_deleted'
    add_index :amenity_types, [:name, :instance_id], unique: true

    remove_duplicated_instance_admins
    add_index :instance_admins, [:user_id, :instance_id], unique: true, where: '(deleted_at IS NULL)'

    remove_duplicated_reviews
    begin
      add_index :reviews, [:user_id, :reviewable_id, :reviewable_type, :subject, :instance_id], where: "(deleted_at IS NULL)", unique: true, name: 'index_reviews_on_user_reviewable_and_type_and_subject'
    rescue
      puts $!.message
    end
  end

  private

  def remove_duplicated_instance_admins
    TmpInstanceAdmin
      .all
      .group_by { |i| [i.instance_id, i.user_id] }
      .flat_map { |_, r| r[1..-1] }
      .each(&:destroy)
  end

  def remove_duplicated_reviews
    grouped = TmpReview
              .all
              .group_by { |i| [i.user_id, i.reviewable_id, i.reviewable_type, i.subject, i.instance_id] }

    #remove all without subject
    grouped
      .select {|_,r| r.count > 1}
      .flat_map { |_, r| r }
      .select { |i| i.subject.blank? }
      .each(&:destroy)

    #remove duplicates
    grouped.flat_map { |_, r| r[1..-1] }.each(&:destroy)
  end
end
