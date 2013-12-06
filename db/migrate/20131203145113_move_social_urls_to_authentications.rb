class MoveSocialUrlsToAuthentications < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  class Authentication < ActiveRecord::Base
    belongs_to :user
    attr_accessible :user_id, :provider, :uid, :info
    serialize :info, Hash
  end

  def change

    add_column :authentications, :profile_url, :text

    Authentication.where(provider: ['facebook', 'twitter', 'linkedin']).each do |authentication|
      url = case authentication.provider
      when 'facebook'
        authentication.info['urls']['Facebook']
      when 'twitter'
        authentication.info['urls']['Twitter']
      when 'linkedin'
        authentication.info['urls']['public_profile']
      end if authentication.info.present? && authentication.info['urls'].present?

      url ||= authentication.user.read_attribute(:"#{authentication.provider}_url")
      authentication.update_column(:profile_url, url) if url.present?
    end

    remove_column :users, :facebook_url
    remove_column :users, :twitter_url
    remove_column :users, :linkedin_url
    remove_column :users, :instagram_url
  end

end
