module MarketplaceReports
  class UserReportExporter
    def initialize(collection)
      @collection = collection
    end

    def export_data_to_csv
      attribute_names = @collection.first.try(:attributes).try(:keys)
      properties_columns = get_hstore_columns

      csv = CSV.generate do |csv|
        csv << [attribute_names, 'user_categories', 'followed_topics',
                properties_columns.map { |ca_with_profile_type| ca_with_profile_type[:name] }].flatten
  
        profile_types = properties_columns.map { |ca_with_profile_type| ca_with_profile_type[:profile_type] }.uniq

        @collection.each do |record|
          values = record.attributes.values
          profile_properties = {}
          profile_types.each { |profile_type| profile_properties[profile_type] = record.send("#{profile_type}_properties").to_h }
  
          if record.default_profile.present?
            values << record.default_profile.categories.pluck(:name).join(',')
          else
            values << ''
          end
          values << Topic.joins("inner join activity_feed_subscriptions afs on afs.followed_id = topics.id and afs.followed_type = 'Topic'").where('afs.follower_id = ?', record.id).pluck(:name).join(',')
  
          properties_columns.each do |ca_with_profile_type|
            values << profile_properties[ca_with_profile_type[:profile_type]][ca_with_profile_type[:name]]
          end
  
          csv << values
        end
      end
  
      csv
    end

    private

    def get_hstore_columns
      CustomAttributes::CustomAttribute.with_deleted.where(target_type: 'InstanceProfileType').order('name ASC').map do |ca|
        { profile_type: ca.target.profile_type, name: ca.name }
      end
    end
  end
end
