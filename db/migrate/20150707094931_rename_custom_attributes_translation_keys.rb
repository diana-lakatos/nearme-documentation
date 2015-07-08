class RenameCustomAttributesTranslationKeys < ActiveRecord::Migration
  def up
    TransactableType.unscoped.where(deleted_at: nil).find_each do |tt|
      where_cond = []
      
      [tt.translation_key_suffix, tt.translation_key_pluralized_suffix].each do |suffix|
        %w(labels hints placeholders prompts valid_values).each do |group|
          where_cond << "key ILIKE 'simple_form.#{group}.#{suffix}.%'"
        end
      end
      
      tt.instance.translations.where(where_cond.join(' OR ')).find_each do |translation|
        group = translation.key.match(/simple_form\.(labels|hints|placeholders|prompts|valid_values)\./)[1]
        new_key = translation.key.gsub(/simple_form\.(labels|hints|placeholders|prompts|valid_values)\.(#{tt.translation_key_suffix}|#{tt.translation_key_pluralized_suffix})\./, "#{tt.translation_namespace}.#{group}.")
        p "Updating translation key: #{translation.key} to #{new_key}"
        translation.update! key: new_key
      end
    end
  end
end
