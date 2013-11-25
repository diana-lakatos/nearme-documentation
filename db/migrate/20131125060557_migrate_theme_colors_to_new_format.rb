class MigrateThemeColorsToNewFormat < ActiveRecord::Migration
  def up
    Theme.find_each do |theme|
      Theme::COLORS.each do |color|
        old_color = theme.send("color_#{color}")
        if old_color
          theme.send("color_#{color}=", old_color.delete('#'))
        end
      end
      theme.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
