namespace :project_to_transactable do

  task migrate_data: :environment do
    class Project < ActiveRecord::Base
      has_paper_trail
      acts_as_paranoid
      auto_set_platform_context
      scoped_to_platform_context

      # This must go before has_custom_attributes because of how the errors for the custom
      # attributes are added to the instance
      include CommunityValidators
      has_custom_attributes target_type: 'ProjectType', target_id: :transactable_type_id

      include CreationFilter
      include QuerySearchable

      attr_reader :collaborator_email
      attr_readonly :followers_count

      DEFAULT_ATTRIBUTES = %w(name description)
      SORT_OPTIONS = ['All', 'Featured', 'Most Recent', 'Most Popular', 'Collaborators']

      belongs_to :creator, -> { with_deleted }, class_name: "User"
      counter_culture :creator,
        column_name: -> (p) { p.enabled? ? 'projects_count' : nil },
        column_names: { ["projects.draft_at IS NULL AND projects.deleted_at IS NULL"] => 'projects_count' }

      belongs_to :transactable_type, -> { with_deleted }, foreign_key: 'transactable_type_id'

      has_many :activity_feed_events, as: :followed, dependent: :destroy
      has_many :activity_feed_subscriptions, as: :followed, dependent: :destroy
      has_many :approved_project_collaborators, -> { approved }, class_name: 'ProjectCollaborator', dependent: :destroy
      has_many :comments, as: :commentable, dependent: :destroy
      has_many :collaborating_users, through: :approved_project_collaborators, source: :user
      has_many :data_source_contents, through: :project_topics
      has_many :feed_followers, through: :activity_feed_subscriptions, source: :follower
      has_many :links, dependent: :destroy, as: :linkable
      has_many :photos, as: :owner, dependent: :destroy do
        def thumb
          (first || build).thumb
        end

        def except_cover
          offset(1)
        end
      end
      has_many :project_collaborators, dependent: :destroy
      has_many :project_topics, dependent: :destroy
      has_many :topics, through: :project_topics
      has_many :user_messages, as: :thread_context, inverse_of: :thread_context
      has_many :wish_list_items, as: :wishlistable

      scope :by_topic, -> (topic_ids) { includes(:project_topics).where(project_topics: {topic_id: topic_ids}) if topic_ids.present?}
      scope :seek_collaborators, -> { where(seek_collaborators: true) }
      scope :featured, -> { enabled.where(featured: true) }
      scope :by_search_query, lambda { |query|
        where("name ilike ? or description ilike ? or summary ilike ?", query, query, query)
      }
      scope :with_date, ->(date) { where(created_at: date) }
      scope :enabled, -> { where(draft_at: nil) }

      scope :feed_not_followed_by_user, -> (current_user) {
        where.not(id: current_user.feed_followed_projects.pluck(:id))
      }

      accepts_nested_attributes_for :photos, allow_destroy: true
      accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true

      attr_accessor :photo_not_required

      validates :photos, length: {minimum: 1}, unless: ->(record) { record.draft? || record.photo_not_required || !record.transactable_type.enable_photo_required }
      validates :topics, length: {:minimum => 1}, unless: ->(record) { record.draft? }
      validates :name, :description, :summary, presence: true, unless: ->(record) { record.draft? }
      validates :name, :summary, length: { maximum: 140 }, unless: ->(record) { record.draft? }
      validates :description, length: { maximum: 5000 }, unless: ->(record) { record.draft? }

      validates_with CustomValidators

      # TODO: move to form object
      after_save :trigger_workflow_alert_for_added_collaborators, unless: ->(record) { record.draft? }

      after_destroy :fix_counter_caches
      after_destroy :fix_counter_caches_after_commit

      before_restore :restore_photos
      before_restore :restore_links
      before_restore :restore_project_collaborators

      delegate :custom_validators, to: :transactable_type

      def self.custom_order(order)
        case order
        when /most recent/i
          order('projects.created_at DESC')
        when /most popular/i
          #TODO check most popular sort after followers are implemented
          order('projects.followers_count DESC')
        when /collaborators/i
          group('projects.id').
            joins("LEFT OUTER JOIN project_collaborators pc ON projects.id = pc.project_id AND (pc.approved_by_owner_at IS NOT NULL AND pc.approved_by_user_at IS NOT NULL AND pc.deleted_at IS NULL)").
            order('count(pc.id) DESC')
        when /featured/i
          where(featured: true)
        when /pending/i
          where("(SELECT pc.id from project_collaborators pc WHERE pc.project_id = projects.id AND pc.user_id = 6520 AND ( approved_by_user_at IS NULL OR approved_by_owner_at IS NULL) AND deleted_at IS NULL LIMIT 1) IS NOT NULL")
        else
          if PlatformContext.current.instance.is_community?
            order('projects.followers_count DESC')
          else
            all
          end
        end
      end

      after_commit :user_created_project_event, on: :create, unless: ->(record) { record.draft? }
      def user_created_project_event
        event = :user_created_project
        user = self.creator.try(:object).presence || self.creator
        affected_objects = [user] + self.topics
        ActivityFeedService.create_event(event, self, affected_objects, self)
      end
      after_update :user_created_project_event_on_publish
      def user_created_project_event_on_publish
        if draft_at_changed?
          user_created_project_event
        end
      end

      def to_liquid
        @project_drop ||= ProjectDrop.new(self)
      end

      def draft?
        draft_at.present?
      end

      def enabled?
        draft_at.nil?
      end

      def cover_photo
        photos.first || Photo.new
      end

      def build_new_collaborator
        OpenStruct.new(email: nil)
      end

      def new_collaborators
        (@new_collaborators || []).empty? ? [OpenStruct.new(email: nil)] : @new_collaborators
      end

      def new_collaborators_attributes=(attributes)
        @new_collaborators = (attributes || {}).values.map { |c| c[:email] }.reject(&:blank?).uniq.map { |email| OpenStruct.new(email: email) }
      end

      def trigger_workflow_alert_for_added_collaborators
        return true if @new_collaborators.nil?
        @new_collaborators.each do |collaborator|
          collaborator_email = collaborator.email.try(:downcase)
          next if collaborator_email.blank?
          user = User.find_by(email: collaborator_email)
          next unless user.present?
          unless self.project_collaborators.for_user(user).exists?
            pc = self.project_collaborators.build(user: user, email: collaborator_email, approved_by_owner_at: Time.zone.now)
            pc.save!
            # WorkflowStepJob.perform(WorkflowStep::ProjectWorkflow::CollaboratorAddedByProjectOwner, pc.id)
          end
        end
      end


      def restore_photos
        self.photos.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', self.deleted_at - 30.seconds, self.deleted_at + 30.seconds).each do |photo|
          begin
            photo.restore(recursive: true)
          rescue
          end
        end
      end

      def restore_links
        self.links.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', self.deleted_at - 30.seconds, self.deleted_at + 30.seconds).each do |link|
          begin
            link.restore(recursive: true)
          rescue
          end
        end
      end

      def restore_project_collaborators
        self.project_collaborators.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', self.deleted_at - 30.seconds, self.deleted_at + 30.seconds).each do |pc|
          begin
            pc.restore(recursive: true)
          rescue
          end
        end
      end

      # Counter culture does not play along well (on destroy) with acts_as_paranoid
      def fix_counter_caches
        if self.creator && !self.creator.destroyed?
          self.creator.update_column(:projects_count, self.creator.projects.where(draft_at: nil).count)
        end
        true
      end

      # Counter culture does not play along well (on destroy) with acts_as_paranoid
      def fix_counter_caches_after_commit
        execute_after_commit { fix_counter_caches }
        true
      end

      class NotFound < ActiveRecord::RecordNotFound; end
    end

    class ProjectDrop < BaseDrop
      attr_reader :project

      # id
      #   id of project as integer
      # name
      #   name of project as string
      delegate :id, :name, :description, :data_source_contents, :creator, :photos, to: :project

      def initialize(project)
        @project = project
      end

      # url to the "space listing" version of a first photo
      def cover_photo_url
        ActionController::Base.helpers.asset_url(@project.cover_photo.try(:image_url, :project_cover))
      end

      # url to the "large" version of a first photo
      def photo_large_url
        ActionController::Base.helpers.asset_url(@project.photos.first.try(:image_url, :large))
      end

      def show_path
        routes.project_path(@project)
      end

      def show_url
        urlify(show_path)
      end

      def edit_url
        urlify(routes.edit_dashboard_project_type_project_path(@project.transactable_type, @project))
      end

      def edit_url_with_token
        urlify(routes.edit_dashboard_project_type_project_path(@project.transactable_type, @project, token_key => @project.creator.try(:temporary_token), anchor: :collaborators))
      end

      def topics_names
        project.topics.pluck(:name).join(', ')
      end

    end

    class ProjectCollaborator < ActiveRecord::Base
      acts_as_paranoid
      auto_set_platform_context
      scoped_to_platform_context

      belongs_to :user

      counter_culture :user,
        column_name: ->(p) { p.approved? ? 'project_collborations_count' : nil },
        column_names: { ["project_collaborators.approved_by_owner_at IS NOT NULL AND project_collaborators.approved_by_user_at IS NOT NULL AND project_collaborators.deleted_at IS NULL"] => 'project_collborations_count' }

      belongs_to :project

      validates :user, presence: { message: I18n.t(:not_exist)}
      validates_uniqueness_of :user, scope: :project_id

      validates :project, presence: true

      scope :approved, -> { where.not(approved_by_owner_at: nil, approved_by_user_at: nil) }
      scope :for_user, -> (user) { user.present? ? where('user_id = ? OR email = ?', user.id, user.email) : [] }

      def name
        @name ||= user.try(:name)
      end

      def pending?
        !approved?
      end

      def approved?
        approved_by_owner_at.present? && approved_by_user_at.present?
      end

      def approved=(approve=nil)
        self.update_attribute(:approved_by_owner_at, Time.zone.now) if approve.present?
      end

      def approve_by_user!
        self.update_attribute(:approved_by_user_at, Time.now)
      end

      def approved_by_user?
        approved_by_user_at.present?
      end

      def approved_by_owner?
        approved_by_owner_at.present?
      end

    end

    class ProjectTopic < ActiveRecord::Base
      has_paper_trail
      auto_set_platform_context
      scoped_to_platform_context

      belongs_to :instance
      belongs_to :project
      belongs_to :topic

      has_many :data_source_contents, through: :topic
    end

    class GroupProject < ActiveRecord::Base
      has_paper_trail
      auto_set_platform_context
      scoped_to_platform_context

      belongs_to :instance
      belongs_to :group
      belongs_to :project
    end

    TransactableType.class_eval do
      def auto_accept_invitation_as_collaborator?
        false
      end
    end

    Transactable.reset_column_information

    Instance.find_each do |instance|
      next if !instance.is_community?

      instance.set_context!

      # We delete stray TransactableType object
      stray_tt = TransactableType.find_by_id(444)
      stray_tt.delete if stray_tt.present?

      WorkflowStep.where('associated_class like ?', 'WorkflowStep::CollaboratorWorkflow%').destroy_all

      ActivityFeedEvent.where("event like '%project%'").find_each do |activity_feed_event|
        event = activity_feed_event.event
        new_event = event.gsub('project', 'transactable')
        activity_feed_event.update_column(:event, new_event)
      end

      ProjectType.find_each do |project_type|
        transactable_type = project_type.dup
        transactable_type.type = nil
        transactable_type.show_path_format = '/:transactable_type_id/:id'
        transactable_type.save!
        # Avoid weird issue with STI
        transactable_type = TransactableType.find_by_id(transactable_type.id)

        transactable_type_action_type = TransactableType::NoActionBooking.new
        transactable_type_action_type.transactable_type_id = transactable_type.id
        transactable_type_action_type.enabled = true
        transactable_type_action_type.save!

        project_type.custom_validators.each do |custom_validator|
          next if custom_validator.field_name == 'summary'
          new_custom_validator = custom_validator.dup
          new_custom_validator.validatable = transactable_type
          new_custom_validator.validation_rules = custom_validator.validation_rules
          new_custom_validator.validation_rules[:presence] = {} if ['name', 'description'].include?(custom_validator.field_name)
          new_custom_validator.max_length = 140 if custom_validator.field_name == 'name'
          new_custom_validator.max_length = 5000 if custom_validator.field_name == 'description'
          new_custom_validator.save!
        end

        summary_attribute = transactable_type.custom_attributes.build
        summary_attribute.name = 'summary'
        summary_attribute.transactable_type_id = transactable_type.id
        summary_attribute.attribute_type = 'string'
        summary_attribute.html_tag = 'textarea'
        # TODO, add presence rule manually from the interface, we can't add it
        # now because it's missing for some projects
        #summary_attribute.validation_rules = { length: { maximum: 140 }, presence: {} }
        summary_attribute.validation_rules = { length: { maximum: 140 } }
        summary_attribute.label = 'Summary'
        summary_attribute.target = transactable_type
        summary_attribute.placeholder = 'Summarize this project in less than 140 characters'
        summary_attribute.save!


        video_url_attribute = transactable_type.custom_attributes.build
        video_url_attribute.name = 'video_url'
        video_url_attribute.transactable_type_id = transactable_type.id
        video_url_attribute.attribute_type = 'string'
        video_url_attribute.html_tag = 'input'
        # TODO, add presence rule manually from the interface, we can't add it
        # now because it's missing for some projects
        #video_url_attribute.validation_rules = { length: { maximum: 140 }, presence: {} }
        #video_url_attribute.validation_rules = { length: { maximum: 140 } }
        video_url_attribute.label = 'Video URL'
        video_url_attribute.target = transactable_type
        #video_url_attribute.placeholder = 'Summarize this project in less than 140 characters'
        video_url_attribute.save!

        project_type.projects.each do |project|
          transactable = Transactable.new
          transactable.transactable_type = transactable_type
          transactable.creator = project.creator
          #project.properties.each do |k, v|
          #  transactable.properties[k] = v
          #end
          transactable.wish_list_items_count = project.wish_list_items_count
          transactable.name = project.name
          transactable.description = project.description
          transactable.external_id = project.external_id
          transactable.seek_collaborators = project.seek_collaborators
          transactable.draft = project.draft_at
          transactable.followers_count = project.followers_count
          transactable.build_action_type
          transactable.photo_not_required = true
          transactable.location_not_required = true
          transactable.action_type.transactable_type_action_type_id = transactable_type_action_type.id
          transactable.properties.summary = project.summary
          transactable.properties.video_url = project.properties.video_url if project.properties.respond_to?(:video_url)
          transactable.skip_activity_feed_event = true
          transactable.featured = project.featured
          transactable.save!
          transactable.update_columns(created_at: project.created_at, updated_at: project.updated_at)
          project.update_columns(transactable_id: transactable.id)

          ActivityFeedEvent.where(followed: project).find_each do |activity_feed_event|
            activity_feed_event.update_columns(followed_id: transactable.id, followed_type: 'Transactable')
          end

          ActivityFeedEvent.where("'Project_#{project.id}' = ANY(affected_objects_identifiers)").find_each do |activity_feed_event|
            new_affected_objects_identifiers = activity_feed_event.affected_objects_identifiers.collect do |affected_object|
              if affected_object == "Project_#{project.id}"
                "Transactable_#{transactable.id}"
              else
                affected_object
              end
            end

            activity_feed_event.update_columns(affected_objects_identifiers: new_affected_objects_identifiers)
          end

          ActivityFeedEvent.where(event_source: project).find_each do |activity_feed_event|
            activity_feed_event.update_columns(event_source_id: transactable.id, event_source_type: 'Transactable')
          end

          ActivityFeedSubscription.where(followed: project).find_each do |activity_feed_subscription|
            activity_feed_subscription.update_columns(followed_id: transactable.id, followed_type: 'Transactable')
          end

          ActivityFeedSubscription.where(followed_identifier: "Project_#{project.id}").find_each do |activity_feed_subscription|
            activity_feed_subscription.update_columns(followed_identifier: "Transactable_#{transactable.id}")
          end

          ProjectCollaborator.where(project: project).find_each do |project_collaborator|
            puts project.id
            transactable_collaborator = TransactableCollaborator.new
            transactable_collaborator.instance_id = instance.id
            transactable_collaborator.user_id = project_collaborator.user_id
            transactable_collaborator.transactable_id = transactable.id
            transactable_collaborator.approved_by_owner_at = project_collaborator.approved_by_owner_at
            transactable_collaborator.approved_by_user_at = project_collaborator.approved_by_user_at
            transactable_collaborator.email = project_collaborator.email
            begin
            transactable_collaborator.save!
            transactable_collaborator.update_columns(created_at: project_collaborator.created_at, updated_at: project_collaborator.updated_at)
            rescue
              puts "Couldn't create project collaborator with id=#{project_collaborator.id}"
            end
          end

          GroupProject.where(project: project).find_each do |group_project|
            group_transactable = GroupTransactable.new
            group_transactable.group = group_project.group
            group_transactable.transactable_id = transactable.id
            group_transactable.save!
          end

          Comment.where(commentable: project).find_each do |comment|
            comment.update_columns(commentable_id: transactable.id, commentable_type: 'Transactable')
          end

          Link.where(linkable: project).find_each do |link|
            link.update_columns(linkable_id: transactable.id, linkable_type: 'Transactable')
          end

          Photo.where(owner: project).find_each do |photo|
            photo.update_columns(owner_id: transactable.id, owner_type: 'Transactable')
          end

          ProjectTopic.where(project: project).find_each do |project_topic|
            transactable_topic = TransactableTopic.new
            transactable_topic.transactable_id = transactable.id
            transactable_topic.topic_id = project_topic.topic_id
            transactable_topic.save!
            transactable_topic.update_columns(created_at: project_topic.created_at, updated_at: project_topic.updated_at)
          end

          UserMessage.where(thread_context: project).find_each do |user_message|
            user_message.update_columns(thread_context_id: transactable.id, thread_context_type: 'Transactable')
          end

          WishListItem.where(wishlistable: project).find_each do |wish_list_item|
            wish_list_item.update_columns(wishlistable_id: transactable.id, wishlistable_type: 'Transactable')
          end

          UserStatusUpdate.where(updateable_id: project.id, updateable_type: 'Project').find_each do |user_status_update|
            user_status_update.update_columns(updateable_id: transactable.id, updateable_type: 'Transactable')
          end
        end

        # We need to remove project types from the DB otherwise the app can't be loaded because
        project_type.custom_settings[:former_project_type] = true
        project_type.custom_settings[:new_transactable_type_id] = transactable_type.id
        project_type.save(validate: false)
        project_type.delete
      end

      # We handle deleted projects
      ActivityFeedEvent.where(followed_type: 'Project').find_each do |activity_feed_event|
        if activity_feed_event.followed.blank? || activity_feed_event.followed.deleted_at.present?
          activity_feed_event.destroy
        end
      end

      Workflow.where(workflow_type: 'project_workflow').find_each do |workflow|
        workflow.name = workflow.name.gsub(/Project/, 'Collaborator')
        workflow.workflow_type = 'collaborator_workflow'
        workflow.save!

        workflow.workflow_steps.each do |workflow_step|
          workflow_step.associated_class = workflow_step.associated_class.gsub(/ProjectWorkflow/, 'CollaboratorWorkflow')
          workflow_step.associated_class = workflow_step.associated_class.gsub(/Project/, 'Transactable')
          workflow_step.name = workflow_step.associated_class.demodulize.gsub(/(?<=[a-z])(?=[A-Z])/, ' ')
          workflow_step.save

          workflow_step.workflow_alerts.find_each do |workflow_alert|
            workflow_alert.subject = workflow_alert.subject.gsub(/project/, 'transactable')
            workflow_alert.template_path = workflow_alert.template_path.gsub(/project_mailer/, 'transactable_mailer')
            workflow_alert.template_path = workflow_alert.template_path.gsub(/project/, 'transactable')
            workflow_alert.name = workflow_alert.name.gsub(/project/, 'transactable')
            workflow_alert.name = workflow_alert.name.gsub(/Project/, 'Transactable')
            workflow_alert.save
          end
        end
      end

    end

  end

end
