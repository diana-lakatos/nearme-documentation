# frozen_string_literal: true
namespace :migrate do
  task longtail: :environment do
    Instance.first.set_context!
    ThirdPartyIntegration::LongtailIntegration.create! do |longtail_integration|
      longtail_integration.environment = 'production'
      longtail_integration.settings = {
        token: '341413f7e17c0a48eb605e08bdbce7d2',
        page_slug: 'workspace'
      }
    end

    Instance.find(130).set_context!
    ThirdPartyIntegration::LongtailIntegration.create! do |longtail_integration|
      longtail_integration.environment = 'production'
      longtail_integration.settings = {
        token: '07eacc2262eec5d0216561b4f6c8725c',
        page_slug: 'storage'
      }
    end

=begin
    Instance.first.set_context!
    ThirdPartyIntegration::LongtailIntegration.create! do |longtail_integration|
      longtail_integration.environment = 'development'
      longtail_integration.settings = {
        token: 'c3ac011214f481a580dae3fa3a3e8cf9',
        page_slug: 'workspace'
      }
    end
=end
  end

  task user_avatars: :environment do
    arr = []
    scope = User.with_deleted.where.not(avatar: nil).where('id > ?', 32_336)
    count = scope.count
    index = 0
    puts "Migrating production california"
    scope.find_each do |user|
      legacy_path = "s3://near-me-production/instances/universal/uploads/images/user/avatar/#{user.id}"
      new_path = "s3://near-me-production/instances/#{user.instance_id}/uploads/images/user/avatar/#{user.id}"
      cmd = "aws s3 sync #{legacy_path} #{new_path} --acl public-read"
      `#{cmd}`
      index += 1
      puts "#{index}/#{count}" if index % 100 == 0
      arr << user.id
    end
    puts "Migrating oregon production"

    legacy_path = "s3://near-me-oregon/instances/universal/uploads/images/user/avatar"
    new_path = "s3://near-me-oregon/instances/132/uploads/images/user/avatar"
    cmd = "aws s3 sync #{legacy_path} #{new_path} --acl public-read"
    puts cmd
    `#{cmd}`

    puts arr.join(', ')
  end

end

