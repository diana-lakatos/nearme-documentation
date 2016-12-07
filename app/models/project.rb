# frozen_string_literal: true
class Project  < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
end
