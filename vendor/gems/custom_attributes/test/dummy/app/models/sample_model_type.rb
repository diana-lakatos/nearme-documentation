class SampleModelType < ActiveRecord::Base

  acts_as_custom_attributes_set

  has_many :sample_models

  def translation_namespace
    "current_name"
  end

  def translation_namespace_was
    "current_name_was"
  end
end
