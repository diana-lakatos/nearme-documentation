FactoryGirl.define do

  factory :partner do
    name 'Super Partner'
    instance_id { (Instance.default_instance.presence || FactoryGirl.create(:instance)).id }
  end

end
