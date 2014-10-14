module CustomAttributes
  class CustomAttribute < ActiveRecord::Base
    include CustomAttributes::Concerns::Models::CustomAttribute
  end
end

