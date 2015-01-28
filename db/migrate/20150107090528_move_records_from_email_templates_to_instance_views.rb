class MoveRecordsFromEmailTemplatesToInstanceViews < ActiveRecord::Migration
  class EmailTemplate < ActiveRecord::Base
    belongs_to :theme
  end

  class InstanceView < ActiveRecord::Base
  end

  class Instance < ActiveRecord::Base
    def self.default_instance
      where(name: "DesksNearMe").first || self.first
    end
  end

  class Theme < ActiveRecord::Base
    belongs_to :owner, :polymorphic => true
    def instance_id
      case owner_type
      when "Instance"
        owner_id
      else
        raise "Unknown owner #{owner_type}"
      end
    end
  end

  class PlatformContext

    attr_reader :platform_context_detail, :instance, :theme
    def initialize(object = nil)
      initialize_with_instance(Instance.default_instance)
    end

    def initialize_with_instance(instance)
      @instance = instance
      @theme = Theme.where(owner_type: 'Instance', owner_id: instance.id).first

      @platform_context_detail = @instance
      self
    end

    def self.current
      Thread.current[:platform_context]
    end

    def self.current=(platform_context)
      Thread.current[:platform_context] = platform_context
    end
  end

  def up
    InstanceView.where(view_type: nil).update_all(view_type: 'view')
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new
      puts "Creating workflow for instance: #{i.name}"
      Utils::DefaultAlertsCreator.new.create_all_workflows!
    end

    Theme.find_each do |t|
      puts "Finding email templates for theme: #{t.id}"
      EmailTemplate.where(theme_id: t.id).find_each do |email_template|
        puts "Processing #{email_template.path}"
        iv = InstanceView.find_or_initialize_by(instance_id: t.instance_id, locale: 'en', view_type: 'email', partial: false, path: email_template.path, format: 'text', handler: 'liquid')
        iv.body = email_template.text_body
        iv.save!
        iv = InstanceView.find_or_initialize_by(instance_id: t.instance_id, locale: 'en', view_type: 'email', partial: false, path: email_template.path, format: 'html', handler: 'liquid')
        iv.body = email_template.html_body
        iv.save!
        if(workflow_alert = WorkflowAlert.where(instance_id: t.instance_id, template_path: email_template.path).first).present?
          puts "Changing #{workflow_alert.subject} to #{email_template.subject}"
          workflow_alert.subject = email_template.subject if email_template.subject.present?
          workflow_alert.from = email_template.from if email_template.from.present?
          workflow_alert.reply_to = email_template.no_reply if email_template.reply_to.present?
          workflow_alert.bcc = email_template.bcc if email_template.bcc.present?
          workflow_alert.save!
        else
          puts "Skipping - workflow alert has not been not created yet"
        end
      end
    end

  end

  def down
  end
end
