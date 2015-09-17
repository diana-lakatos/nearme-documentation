class PopulateBookableNounsTranslations < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      puts "Processing #{i.name}"
      i.set_context!
      i.transactable_types.find_each do |tt|
        name = tt.bookable_noun.presence || tt.name
        puts "\tProcessing translation for tt id=#{tt.id} - #{tt.name}"
        if name
          puts "\t\tCreating translation for name #{tt.name}"
          tt.translation_manager.create_plural_and_singular_translation('name', name)
        else
          puts "\t\tSkipping name"
        end
        if tt.lessor.present?
          puts "\t\tCreating translation for lessor #{tt.lessor}"
          tt.translation_manager.create_plural_and_singular_translation('lessor', tt.lessor)
        else
          puts "\t\tSkipping lessor"
        end
        if tt.lessee.present?
          puts "\t\tCreating translation for lessee #{tt.lessee}"
          tt.translation_manager.create_plural_and_singular_translation('lessee', tt.lessee)
        else
          puts "\t\tSkipping lessee"
        end
      end
    end
  end

  def down
  end
end
