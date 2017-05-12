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
  property :id, virtual: true
  property :file, virtual: true

  def id
    super.presence || model.id
  end

  delegate :uploader_id, to: :model

  def file_name
    File.basename(file.path.to_s).presence || file.filename
  end

  def file_extension
    File.extname(file.path.to_s.presence || file.filename)&.tr('.', '')
  end

  delegate :url, to: :file, prefix: true

  def file_time
    model.created_at || Time.zone.now
  end

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
