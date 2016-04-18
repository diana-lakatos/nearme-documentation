class UpdateInstanceViewsToNotUseOldSyntaxForAccessingCustomAttributes < ActiveRecord::Migration

  def up
    Instance.find_each do |i|
      puts "Processing #{i.name}"
      i.set_context!
      gsub_rules = [[".job_title_and_company_name", ".job_title"]]
      names = []
      TransactableType.find_each do |st|
        names << st.custom_attributes.pluck(:name)
      end
      names.flatten!
      names.each do |name|
        gsub_rules << ["listing.#{name}", "listing.properties.#{name}"]
        gsub_rules << ["transactable.#{name}", "transactable.properties.#{name}"]
      end
      names = []
      InstanceProfileType.find_each do |ipt|
        names << ipt.custom_attributes.pluck(:name)
      end
      names.flatten!
      names.each do |name|
        gsub_rules << ["user.#{name}", "user.properties.#{name}"]
        gsub_rules << ["creator.#{name}", "creator.properties.#{name}"]
        gsub_rules << ["administrator.#{name}", "administrator.properties.#{name}"]
      end
      names = []
      Spree::ProductType.find_each do |pt|
        names << pt.custom_attributes.pluck(:name)
      end
      names.flatten!
      names.each do |name|
        gsub_rules << ["product.#{name}", "product.properties.#{name}"]
      end

      InstanceView.find_each do |iv|
        bd = gsub_rules.inject(iv.body) { |body, gsub_rule| body.gsub(gsub_rule[0], gsub_rule[1] ) }
        if iv.body != bd
          puts "Updating instance view #{iv.id} - new syntax will be used"
          iv.update_attribute(:body, bd)
        end
      end
    end

  end

  def down
  end

end
