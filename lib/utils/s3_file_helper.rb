# frozen_string_literal: true
require 'aws-sdk'

module Utils
  class S3FileHelper
    attr_accessor :pathname, :bucket_name, :bucket_path, :bucket_region
    attr_reader :client

    def initialize(pathname)
      @pathname      = pathname
      @bucket_name   = 'near-me-db-backups'
      @bucket_path   = 'db_backup'
      @bucket_region = 'us-west-1'

      @key = "#{@bucket_path}/#{@pathname.basename}"
    end

    def upload_file!
      client.put_object bucket: @bucket_name, key: @key, body: @pathname.read, acl: 'private'
    end

    def download_file!
      File.open(@pathname, 'wb') do |file|
        client.get_object bucket: @bucket_name, key: @key do |chunk|
          file.write(chunk)
        end
      end
    end

    def client
      Aws::S3::Client.new(region: bucket_region)
    end
  end
end
