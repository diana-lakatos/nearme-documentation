class AddVariousFieldsToInstances < ActiveRecord::Migration
  def change
    change_table :instances do |t|
      t.string :site_name, :description, :tagline, :support_email, :contact_email, :address,
               :phone_number, :support_url, :blog_url, :twitter_url, :facebook_url
    end

    connection.execute <<-SQL
      UPDATE instances SET site_name='Desks Near Me', tagline='Find a space to work',
                          support_email='support@desksnear.me', contact_email='support@desksnear.me',
                          address='185 Clara St #100, San Francisco CA 94107',
                          phone_number='1.888.998.3375', support_url='http://support.desksnear.me/',
                          blog_url='http://blog.desksnear.me/', twitter_url='https://twitter.com/desksnearme',
                          facebook_url='https://www.facebook.com/DesksNearMe'
      WHERE name='DesksNearMe'
    SQL
  end
end
