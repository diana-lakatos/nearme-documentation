# frozen_string_literal: true
class PageForm < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  belongs_to :page
  belongs_to :form_configuration
end
