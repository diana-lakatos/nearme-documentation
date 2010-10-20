#!/home/deploy/.rvm/bin/ruby

require "rubygems"
require "aws/s3"

user = "desksnearme"
db = "desksnearme_production"
dir = "/home/deploy/backups"
# user = "postgres"
# db = "desksnearme_development"
# dir = "/Users/keith/Code/desksnearme/extras/"
bucket = "desksnearme"

puts "[#{Time.now}] Connecting to S3"
AWS::S3::Base.establish_connection!(
  :access_key_id     => 'AKIAIZ5FVYS75LSDRTYQ',
  :secret_access_key => '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'
)

file_name = "#{db}_#{Time.now.to_i}.tar.gz"
path = File.join(dir, file_name)

puts "[#{Time.now}] Backup up #{db} to #{path}"
`pg_dump -U #{user} -f #{path} -F tar #{db}`

upload_file = "/backups/#{file_name}"
puts "[#{Time.now}] Uploading to S3 #{upload_file}"
AWS::S3::S3Object.store(upload_file, open(path), bucket)

puts "[#{Time.now}] Removing old file..."
File.delete(path)

puts "[#{Time.now}] Done!"
