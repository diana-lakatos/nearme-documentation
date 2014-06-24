class AddInstanceIdToPagesAndThemes < ActiveRecord::Migration
  class Company < ActiveRecord::Base
    belongs_to :instance
  end
  class Partner < ActiveRecord::Base
    belongs_to :instance
  end
  class Instance < ActiveRecord::Base
  end
  class Theme < ActiveRecord::Base
    belongs_to :owner, :polymorphic => true
    def instance
      @instance ||= begin
                      case owner_type
                      when "Instance"
                        owner
                      when "Company"
                        owner.instance
                      when "Partner"
                        owner.instance
                      else
                        raise "Unknown owner #{owner_type}"
                      end
                    end
    end
  end

  class Page < ActiveRecord::Base
    belongs_to :theme

    delegate :instance, to: :theme
  end

  def change
    add_column :pages, :instance_id, :integer
    add_index  :pages, :instance_id

    Page.find_each do |page|
      page.update_column(:instance_id, page.instance.id)
    end

  end
end
