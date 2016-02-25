module QuerySearchable
  extend ActiveSupport::Concern

  included do

    def self.search_by_query(attributes = [], query)
      if query.present?
        words = query.split.map.with_index{|w, i| ["word#{i}".to_sym, "%#{w}%"]}.to_h

        sql = attributes.map do |attrib|
          if self.columns_hash[attrib.to_s].type == :hstore
            attrib = "CAST(avals(#{quoted_table_name}.\"#{attrib}\") AS text)"
          else
            attrib = "#{quoted_table_name}.\"#{attrib}\""
          end
          words.map do |word, value|
            "#{attrib} ILIKE :#{word}"
          end
        end.flatten.join(' OR ')

        where(ActiveRecord::Base.send(:sanitize_sql_array, [sql, words]))
      else
        all
      end
    end
  end

end
