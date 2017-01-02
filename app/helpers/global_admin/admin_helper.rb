# frozen_string_literal: true
module GlobalAdmin::AdminHelper
  def options_for_property_type
    [
      %w(Category category),
      %w(Text text),
      %w(Number number),
      ['Select one',   'select_one'],
      ['Select many',  'select_many'],
      ['Date nad time', 'datetime'],
      ['Yes / No',      'boolean']
    ]
  end
end
