class AddCustomSanitizeOptionToInstances < ActiveRecord::Migration
  class Instance < ActiveRecord::Base
    serialize :custom_sanitize_config, Hash
  end

  def change
    add_column :instances, :custom_sanitize_config, :text

    @instance = Instance.find_by_id(36)
    if @instance.present?
      @instance.update_attribute(:custom_sanitize_config, {
        :elements => %w[embed br],
        :attributes => {
          'embed'    => %w[width height src type],
          'a'        => %w[target]
        },
        :protocols => {
          'embed' => {'src' => %w[http https]}
        }
      })
    end
  end
end
