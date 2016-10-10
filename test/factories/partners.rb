FactoryGirl.define do
  factory :partner do
    name 'Super Partner'
    search_scope_option 'all_associated_listings'

    factory :partner_without_scoping do
      search_scope_option 'no_scoping'
    end
  end
end
