require "rubygems"
require "aws/s3"


# user = "desksnearme"
# db = "desksnearme_production"
# file_name = "/home/deploy/backups/#{db}_#{Time.now.to_i}.tar.gz"
user = "postgres"
db = "desksnearme_development"
dir = "/Users/keith/Code/desksnearme/extras/"
bucket = "desksnearme"

puts "Connecting to S3"
AWS::S3::Base.establish_connection!(
  :access_key_id     => 'AKIAIZ5FVYS75LSDRTYQ',
  :secret_access_key => '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'
)

file_name = "#{db}_#{Time.now.to_i}.tar.gz"
path = File.join(dir, file_name)

puts "Backup up #{db} to #{path}"
`pg_dump -U #{user} -f #{path} -F tar #{db}`

upload_file = "/backups/#{file_name}"
puts "Uploading to S3 #{upload_file}"
AWS::S3::S3Object.store(upload_file, open(file_name), bucket)

puts "Removing old file..."
File.delete(path)

puts "Done!"
