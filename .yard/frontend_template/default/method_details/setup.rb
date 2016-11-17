# frozen_string_literal: true
def init
  super
  sections.first.delete(:source)
end
