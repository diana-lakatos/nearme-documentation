class Form
  extend Forwardable

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  def initialize(attributes)
    store_attributes(attributes)
  end

  def process
    raise "Implement in the subclass"
  end

  private

  def add_errors(errors_messages, attribute = :base)
    errors_messages.each { |e| errors.add(attribute, e) }
  end

  def add_error(error_message, attribute = :base)
    add_errors([error_message], attribute)
  end

  def clear_errors(attribute = :base)
    errors.delete(attribute)
  end

  def has_error?(attribute = :base)
    errors.include?(attribute)
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