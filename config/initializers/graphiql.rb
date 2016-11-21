# frozen_string_literal: true
if defined? GraphiQL
  GraphiQL::Rails.config.initial_query = "{
    users(take: 3){
      name
      profile_path
    }
  }"
end
