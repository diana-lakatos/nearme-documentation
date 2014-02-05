class CreateThemeFonts < ActiveRecord::Migration
  def change
    create_table :theme_fonts do |t|
      t.belongs_to :theme
      t.string :regular_eot
      t.string :regular_svg
      t.string :regular_ttf
      t.string :regular_woff
      t.string :medium_eot
      t.string :medium_svg
      t.string :medium_ttf
      t.string :medium_woff
      t.string :bold_eot
      t.string :bold_svg
      t.string :bold_ttf
      t.string :bold_woff

      t.timestamps
    end
    add_index :theme_fonts, :theme_id
  end
end
