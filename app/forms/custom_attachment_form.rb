# frozen_string_literal: true
class CustomAttachmentForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(options, attr_name)
      Class.new(self) do
        validates :file, options[:validation] if options[:validation].present?
        define_method :file_required? do
          options[:validation].present? && !options[:validation][:presence].nil?
        end

        define_singleton_method(:human_attribute_name) do |_attr|
          attr_name
        end
      end
    end
  end
  property :id, virtual: true
  property :file, virtual: true

  def id
    super.presence || model.id
  end

  def uploader_id
    model.uploader_id
  end

  def file_name
    File.basename(file.path.to_s).presence || file.filename
  end

  def file_extension
    File.extname(file.path.to_s.presence || file.filename)&.tr('.', '')
  end

  def file_url
    file.url
  end

  def file_time
    model.created_at || Time.zone.now
  end

  def file_size
    file.size rescue nil
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
