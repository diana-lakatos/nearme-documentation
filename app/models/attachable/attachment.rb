module Attachable
  class Attachment < ActiveRecord::Base
    has_paper_trail
    auto_set_platform_context
    scoped_to_platform_context
    acts_as_paranoid

    belongs_to :instance
    belongs_to :user
    belongs_to :attachable, polymorphic: true
  end
end
