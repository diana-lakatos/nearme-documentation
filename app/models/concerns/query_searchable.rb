module QuerySearchable
  extend ActiveSupport::Concern

  included do

    def self.search_by_query(attributes = [], query)
      if query.present?
        words = query.split.map.with_index{|w, i| ["word#{i}".to_sym, w]}.to_h
        words_like = query.split.map.with_index{|w, i| ["word_like#{i}".to_sym, "%#{w}%"]}.to_h
        conditions = []
        attributes.map do |attrib|
          if attrib == :tags
            conditions += words.map do |word, value|
              "LOWER(tags.name) = :#{word}"
            end
          else
            if self.columns_hash[attrib.to_s].type == :hstore
              attrib = "CAST(avals(#{quoted_table_name}.\"#{attrib}\") AS text)"
            elsif self.columns_hash[attrib.to_s].type == :integer
              attrib = "CAST(#{quoted_table_name}.\"#{attrib}\" AS text)"
            else
              attrib = "#{quoted_table_name}.\"#{attrib}\""
            end
            conditions += words_like.map do |word, value|
              "#{attrib} ILIKE :#{word}"
            end
          end
        end
        sql = conditions.flatten.join(' OR ')
        result = where(ActiveRecord::Base.send(:sanitize_sql_array, [sql, words.merge(words_like)]))
        result = result.joins(%Q{
          LEFT JOIN "taggings" ON "taggings"."taggable_id" = "users"."id"
          AND "taggings"."context" = 'tags' AND "taggings"."taggable_type" = 'User'
          LEFT JOIN "tags" ON "tags"."id" = "taggings"."tag_id"
          }).uniq if attributes.include?(:tags)
        result
      else
        all
      end
    end

    def self.apply_filter(params = {}, custom_attributes_definition = nil)
      scope = all
      if params.present? && params[:properties].present? && custom_attributes_definition.present?
        params[:properties].each do |name, value|
          definition = custom_attributes_definition.detect { |d| d[CustomAttributes::CustomAttribute::NAME] == name }
          next if definition.nil? || value.blank?
          case definition[CustomAttributes::CustomAttribute::ATTRIBUTE_TYPE]
          when 'string'
            scope = scope.where("#{self.table_name}.properties @> ?", "\"#{definition[CustomAttributes::CustomAttribute::NAME]}\"=>\"#{value}\"")
          else
            raise NotImplementedError.new("Cannot filter by attribute with type: #{definition[CustomAttributes::CustomAttribute::ATTRIBUTE_TYPE]}")
          end
        end
      end
      scope
    end

  end

end
