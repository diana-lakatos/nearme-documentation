# frozen_string_literal: true
FactoryGirl.define do
  factory :dimensions_template do
    sequence(:name) { |n| "dimensions#{n}" }
    weight 100
    width 101
    height 102
    depth 103
  end
end
