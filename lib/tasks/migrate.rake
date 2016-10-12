# Migrate rake task to help with all kind of data migration

namespace :migrate do
  task user_avatars: :environment do
    arr = []
    scope = User.with_deleted.where.not(avatar: nil).where('id > ?', 32_336)
    count = scope.count
    index = 0
    puts 'Migrating production california'
    scope.find_each do |user|
      legacy_path = "s3://near-me-production/instances/universal/uploads/images/user/avatar/#{user.id}"
      new_path = "s3://near-me-production/instances/#{user.instance_id}/uploads/images/user/avatar/#{user.id}"
      cmd = "aws s3 sync #{legacy_path} #{new_path} --acl public-read"
      `#{cmd}`
      index += 1
      puts "#{index}/#{count}" if index % 100 == 0
      arr << user.id
    end
    puts 'Migrating oregon production'

    legacy_path = 's3://near-me-oregon/instances/universal/uploads/images/user/avatar'
    new_path = 's3://near-me-oregon/instances/132/uploads/images/user/avatar'
    cmd = "aws s3 sync #{legacy_path} #{new_path} --acl public-read"
    puts cmd
    `#{cmd}`

    puts arr.join(', ')
  end
end
