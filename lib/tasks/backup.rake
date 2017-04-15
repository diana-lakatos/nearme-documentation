
require 'utils/database_connection_helper'
require 'utils/s3_file_helper'

namespace :backup do
  desc 'Runs pg_dump on current env and stores it in S3.'
  task :capture do
    pathname = Rails.root + Pathname.new('tmp/backup.dump')

    puts "[#{Time.now}] Backing up (pg_dump) ENV DB to #{pathname} (excluding versions tables)"
    `#{Utils::DatabaseConnectionHelper.new(pathname).build_dump_command}`

    puts "[#{Time.now}] Uploading #{pathname} to S3"
    Utils::S3FileHelper.new(pathname).upload_file!

    puts "[#{Time.now}] Removing #{pathname}"
    File.delete(pathname)

    puts "[#{Time.now}] Done"
  end

  desc 'Restores DB from pg_dump in S3.'
  task :restore  do
    pathname = Rails.root + Pathname.new('tmp/backup.dump')

    puts "[#{Time.now}] Downloading from S3 to local #{pathname}"
    Utils::S3FileHelper.new(pathname).download_file!

    puts "[#{Time.now}] Restoring #{pathname} to ENV DB"
    `#{Utils::DatabaseConnectionHelper.new(pathname).build_restore_command}`

    puts "[#{Time.now}] Removing #{pathname}"
    File.delete(pathname)

    puts "[#{Time.now}] Done"
  end

  task :download do
    pathname = Rails.root + Pathname.new('tmp/backup.dump')

    puts "[#{Time.now}] Downloading from S3 to local #{pathname}"
    Utils::S3FileHelper.new(pathname).download_file!
  end

  task :restore_from_local  do
    pathname = Rails.root + Pathname.new('tmp/backup.dump')

    puts "[#{Time.now}] Restoring #{pathname} to ENV DB"
    `#{Utils::DatabaseConnectionHelper.new(pathname).build_restore_command}`

    puts "[#{Time.now}] Done"
  end


end
