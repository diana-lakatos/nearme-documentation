FactoryGirl.define do
  factory :aws_certificate do
    sequence(:name) {|n| "desksnear#{n}.me" }
    instance_id { (PlatformContext.current.instance || FactoryGirl.create(:instance)).id }

    elb_uploaded_at "2016-08-16 16:20:55"
  end
end
