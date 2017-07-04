# frozen_string_literal: true
# Use it with Reform forms
class UniqueValidator < ActiveModel::EachValidator
  UnknownAttributeForForm = Class.new(StandardError)

  def validate_each(form, attribute, value)
    model = form.model_for_property(attribute)

    query = build_query(form, attribute, value, model)
    form.errors.add(attribute, message) if query.count > allowed_count(model)
  end

  private

  SCOPE_RESOLVERS = {
    Symbol => :add_scope_for_column,
    String => :add_scope_for_column,
    Hash => :add_scope_for_hstore_column
  }.freeze

  def build_query(form, attribute, value, model)
    query = model.class.where(attribute => value)

    Array(options[:scope]).each do |field|
      query = send(SCOPE_RESOLVERS[field.class], query, field, form)
    end
    query
  end

  def add_scope_for_column(query, field, form)
    raise UnknownAttributeForForm.new(field) unless form.has_attribute?(field)

    query.where(field => form.send(field))
  end

  def add_scope_for_hstore_column(query, field, form)
    hstore_attr, attribute = field.to_a.first
    raise UnknownAttribute, field unless form.has_attribute?(hstore_attr)

    value = form.send(hstore_attr).send(attribute)
    query.where(
      "#{ActiveRecord::Base.connection.quote_column_name(hstore_attr)} @> hstore(:key, :value)",
      key: attribute,
      value: value
    )
  end

  def allowed_count(model)
    model.persisted? ? 1 : 0
  end

  def message
    options[:message] || :taken
  end
end
