class PopulateInstanceIdForThemes < ActiveRecord::Migration
  class Theme < ActiveRecord::Base
    belongs_to :owner, :polymorphic => true
    def instance
      @instance ||= begin
                      case owner_type
                      when "Instance"
                        owner
                      when "Company"
                        (owner || Company.with_deleted.where(id: owner_id).first).try(:instance)
                      when "Partner"
                        owner.try(:instance)
                      else
                        raise "Unknown owner #{owner_type}"
                      end
                    end
    end
  end

  class Domain < ActiveRecord::Base
    belongs_to :target, polymorphic: true, touch: true
    def instance
      @instance ||= begin
                      case target_type
                      when "Instance"
                        target
                      when "Company"
                        (target || Company.with_deleted.where(id: target_id).first).try(:instance)
                      when "Partner"
                        target.try(:instance)
                      else
                        raise "Unknown target #{target_type}"
                      end
                    end
    end
  end

  def up
    puts "Processing themes"
    Theme.unscoped.find_each do |t|
      if t.instance
        t.update_column(:instance_id, t.instance.id)
      else
        puts "Cannot find instance for theme: #{t.id}"
      end
    end
    puts "Processing domains"
    Domain.unscoped.find_each do |d|
      if d.instance
        d.update_column(:instance_id, d.instance.id)
      else
        puts "Cannot find instance for domain: #{d.id}"
      end
    end

  end

  def down
  end
end
