# frozen_string_literal: true
FactoryGirl.define do
  factory :graph_query do
    name 'users'
    query_string '{users(take: 1){name}}'
  end
end
