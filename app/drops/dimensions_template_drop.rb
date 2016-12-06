# frozen_string_literal: true
class DimensionsTemplateDrop < BaseDrop
  # @return [String] package name and description
  # @todo -- lets put formatting in user's hands
  def label
    format('%s (%s)', source.name, source.description)
  end
end
