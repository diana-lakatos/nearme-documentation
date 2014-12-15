module Utils
  class S3FileHelper
    attr_accessor :pathname, :bucket_name, :bucket_path, :bucket_region

    def initialize(pathname, &block)
      @pathname      = pathname
      @bucket_name   = 'near-me-db-backups'
      @bucket_path   = 'db_backup'
      @bucket_region = 'us-west-1'
      yield self if block_given?
      @s3            = AWS::S3.new(region: bucket_region)
    end

    def upload_file!
      @s3.buckets[@bucket_name].objects["#{@bucket_path}/#{@pathname.basename}"].write(file: @pathname, acl: :authenticated_read)
    end

    def download_file!
      object = @s3.buckets[@bucket_name].objects["#{@bucket_path}/#{@pathname.basename}"]
      File.open(@pathname, 'wb') do |file|
        object.read do |chunk|
          file.write(chunk)
        end
      end
    end
  end
end
