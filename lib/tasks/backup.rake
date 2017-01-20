
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

  task :create_stack_domains, [:stack_name] => :environment do |_t, args|
    stack_name = case args[:stack_name]
    when 'nm-qa-1' then 'qa-1'
    when 'nm-qa-2' then 'qa-2'
    when 'nm-qa-3' then 'qa-3'
    when 'nm-staging' then 'staging'
    when 'nm-staging-oregon' then 'oregon-staging'
    end

    if stack_name.blank?
      puts "Stack name can't be blank"
    else
      Instance.find_each do |instance|
        instance.domains.where(name: "#{instance.name.to_url}.#{stack_name}.near-me.com", instance: instance).first_or_create! do |domain|
          domain.use_as_default = !instance.domains.default.where.not(id: domain.id).exists?
        end
      end
      Domain.all.select { |d| d.name.include?("#{stack_name}.near-me.com") }.each { |d| d.update_column(:secured, true) }

      dnm = Instance.first
      dnm.domains.where(name: "#{stack_name}.near-me.com", instance: dnm).first_or_create! do |domain|
        domain.use_as_default = true
      end
      dnm.update_column(secured: true)

      puts 'Stack domains created.'
    end
  end
end
