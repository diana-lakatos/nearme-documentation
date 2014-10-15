class SampleModelType < ActiveRecord::Base

  acts_as_custom_attributes_set

  has_many :sample_models
end
