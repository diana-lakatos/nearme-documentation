module QuerySearchable
  extend ActiveSupport::Concern

  included do
    def self.search_by_query(attributes = [], query)
      if query.present? && query.try(:split).present?
        words_like = query.split.map.with_index { |w, i| ["word_like#{i}".to_sym, "%#{w}%"] }.to_h
        conditions = []
        tags_conditions = []
        attributes.map do |attrib|
          if attrib == :tags
            tags_conditions += words_like.map do |word, _value|
              "tags.name ILIKE :#{word}"
            end
          else
            if columns_hash[attrib.to_s].type == :hstore
              attrib = "CAST(avals(#{quoted_table_name}.\"#{attrib}\") AS text)"
            elsif columns_hash[attrib.to_s].type == :integer
              attrib = "CAST(#{quoted_table_name}.\"#{attrib}\" AS text)"
            else
              attrib = "#{quoted_table_name}.\"#{attrib}\""
            end
            conditions += words_like.map do |word, _value|
              "#{attrib} ILIKE :#{word}"
            end
          end
        end
        if tags_conditions.any?
          conditions << Tagging.joins(:tag).where("taggings.taggable_id = users.id AND taggings.taggable_type = 'User'")
            .where(tags_conditions.join(' OR ')).exists.to_sql
        end
        sql = conditions.flatten.join(' OR ')
        result = where(ActiveRecord::Base.send(:sanitize_sql_array, [sql, words_like]))
        result
      else
        all
      end
    end

    def self.apply_filter(params = {}, custom_attributes_definition = nil)
      scope = all
      if params.present? && params[:properties].present? && custom_attributes_definition.present?
        params[:properties].each do |name, value|
          definition = custom_attributes_definition.detect { |d| (d.instance_of?(Hash) ? (d[CustomAttributes::CustomAttribute::NAME] == name) : false) }
          next if definition.nil? || value.blank?
          case definition[CustomAttributes::CustomAttribute::ATTRIBUTE_TYPE]
          when 'string'
            scope = scope.where("#{table_name}.properties @> ?", "\"#{definition[CustomAttributes::CustomAttribute::NAME]}\"=>\"#{value}\"")
          else
            fail NotImplementedError.new("Cannot filter by attribute with type: #{definition[CustomAttributes::CustomAttribute::ATTRIBUTE_TYPE]}")
          end
        end
      end
      scope
    end
  end
end
