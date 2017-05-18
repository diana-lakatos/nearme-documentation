module MarketplaceReports
  class UserReportExporter
    def initialize(collection)
      @collection = collection
    end

    def export_data_to_csv
      attribute_names = @collection.first.try(:attributes).try(:keys)
      properties_columns = get_hstore_columns

      csv = CSV.generate do |csv|
        csv << [attribute_names, 'user_categories', 'followed_topics', properties_columns].flatten
  
        @collection.each do |record|
          values = record.attributes.values
          properties = record.send(:properties).to_h
  
          if record.default_profile.present?
            values << record.default_profile.categories.pluck(:name).join(',')
          else
            values << ''
          end
          values << Topic.joins("inner join activity_feed_subscriptions afs on afs.followed_id = topics.id and afs.followed_type = 'Topic'").where('afs.follower_id = ?', record.id).pluck(:name).join(',')
  
          properties_columns.each do |column|
            values << properties[column]
          end
  
          csv << values
        end
      end
  
      csv
    end

    private

    def get_hstore_columns
      CustomAttributes::CustomAttribute.with_deleted.where(target_type: 'InstanceProfileType').order('name ASC').pluck(:name).uniq
    end
  end
end
