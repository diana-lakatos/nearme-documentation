class Form
  extend Forwardable

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def initialize(attributes)
    store_attributes(attributes)
  end

  def process
    raise "NYI"
  end

  private

  def add_errors(errors_messages)
    errors_messages.each { |e| errors.add(:base, e) }
  end

  def add_error(error_message)
    add_errors([error_message])
  end

  def persisted?
    false
  end

  def store_attributes(attribs)
    attribs.each do |name, value|
      send("#{name}=", value) unless value.nil?
    end
  end

end