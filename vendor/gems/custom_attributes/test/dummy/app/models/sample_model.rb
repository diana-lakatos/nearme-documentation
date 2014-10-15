class SampleModel < ActiveRecord::Base

  belongs_to :sample_model_type
  has_custom_attributes target_type: 'SampleModelType', target_id: :sample_model_type_id, hstore_table: :properties

end
