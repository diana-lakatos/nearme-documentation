FactoryGirl.define do
  factory :project do
    name "Project Manhattan"
    description "The Manhattan Project was a research and development project that produced the first nuclear weapon"
    seek_collaborators true
    creator
    photo_not_required true

    trait :featured do
      featured true
    end

    initialize_with do
      new(transactable_type: (ProjectType.first.presence || FactoryGirl.create(:project_type)))
    end

    after(:build) do |project|
      project.topics << FactoryGirl.create(:topic)
    end

    after(:build) do |project|
      project.links << FactoryGirl.create(:link)
    end
  end
end
