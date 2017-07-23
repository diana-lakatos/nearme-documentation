# frozen_string_literal: true
module MarketplaceReports
  class UserReportExporter
    BLACKLISTED_ATTRIBUTES = %w(authentication_token encrypted_password password_salt reset_password_token remember_token admin google_analytics_id avatar_transformation_data avatar_original_url domain_id sms_preferences instance_unread_messages_threads_count metadata payment_token sso_log_out billing_address_id shipping_address_id properties cover_image_transformation_data ui_settings).freeze
    def initialize(collection)
      @collection = collection.includes(user_profiles: :categories)
    end

    def export_data_to_csv
      attribute_names = @collection.first&.attributes&.keys&.reject { |k| BLACKLISTED_ATTRIBUTES.include?(k) }
      properties_columns = get_hstore_columns

      csv = CSV.generate do |csv|
        csv << [attribute_names, 'profile_types', 'user_categories', 'followed_topics',
                properties_columns.map { |ca_with_profile_type| "#{ca_with_profile_type[:name]} (#{ca_with_profile_type[:profile_type]})" }].flatten

        profile_types = properties_columns.map { |ca_with_profile_type| ca_with_profile_type[:profile_type] }.uniq

        @collection.find_each do |record|
          values = attribute_names.map { |attr| record.public_send(attr) }

          user_profiles = profile_types.each_with_object({}) { |pt, memo| memo[pt] = user_profile(record, pt) }

          profile_properties = profile_types.each_with_object({}) { |pt, memo| memo[pt] = (user_profiles[pt]&.properties || {}).to_h }

          values << profile_types.map { |pt| user_profiles[pt].present? ? pt : nil }.compact.join(',')

          values << if record.default_profile.present?
                      record.default_profile.categories.pluck(:name).join(',')
                    else
                      ''
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

    def user_profile(user, parameterized_name)
      user.user_profiles.joins(:instance_profile_type)
          .find_by(instance_profile_types: { parameterized_name: parameterized_name })
    end

    def get_hstore_columns
      CustomAttributes::CustomAttribute.where(target_type: 'InstanceProfileType').order('name ASC').map do |ca|
        { profile_type: ca.target.parameterized_name, name: ca.name }
      end
    end
  end
end
