# frozen_string_literal: true
class CustomAttachmentForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(options, attr_name)
      Class.new(self) do
        define_method :file_required? do
          options[:validation].present? && !options[:validation][:presence].nil?
        end
        add_validation(:file, options)

        define_singleton_method(:human_attribute_name) do |_attr|
          attr_name
        end
      end
    end
  end

  # @!attribute id
  #   @return [Integer] numeric identifier for the custom attachment
  property :id, virtual: true

  # @!attribute file
  #   @return [File] file object associated with the custom attachment
  property :file, virtual: true

  def id
    super.presence || model.id
  end

  # @!method uploader_id
  #   @return [Integer] numeric identifier for the uploader
  delegate :uploader_id, to: :model

  # @return [String] file name for the associated file
  def file_name
    File.basename(file.path.to_s).presence || file.filename
  end

  # @return [String] file extension for the associated file
  def file_extension
    File.extname(file.path.to_s.presence || file.filename)&.tr('.', '')
  end

  # @!method url
  #   @return [String] URL to the associated file
  delegate :url, to: :file, prefix: true

  # @return [Time] date when the associated object was created
  def file_time
    model.created_at || Time.zone.now
  end

  # @return [Integer] size of the associated file in bytes
  def file_size
    file.size
  rescue
    nil
  end

  def file
    super.presence || model.file
  end

  def file=(value)
    super(value)
    if valid?
      model.file = value
      model.save!
      super(model.file)
    end
  end
end
