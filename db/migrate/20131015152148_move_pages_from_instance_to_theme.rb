class MovePagesFromInstanceToTheme < ActiveRecord::Migration

  class Page < ActiveRecord::Base
    belongs_to :theme
    belongs_to :instance
  end

  class Theme < ActiveRecord::Base
    belongs_to :owner, :polymorphic => true
  end

  def up
    add_column :pages, :theme_id, :integer
    add_index :pages, :theme_id

    Page.all.each do |p|
      # Page Theme is the Theme of the Instance that owns the Page
      p.theme_id = Theme.where(owner_type: 'Instance', owner_id: p.instance_id).first.try(:id)
      p.save
    end

    remove_column :pages, :instance_id
  end


  def down
    add_column :pages, :instance_id, :integer

    Page.all.each do |p|
      p.instance_id = Theme.find(p.theme_id).instance.id rescue nil
      p.save
    end

    remove_column :pages, :theme_id
  end
end
