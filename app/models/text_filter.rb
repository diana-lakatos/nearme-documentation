class TextFilter < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :creator, class_name: 'User'
  belongs_to :instance, inverse_of: :text_filters

end

