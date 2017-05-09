# frozen_string_literal: true
class AddGraphQueryToSpacerUserMessagesQuestions < ActiveRecord::Migration
  def up
    Instances::InstanceFinder.get(:spacercom, :spacerau).each do |i|
      i.set_context!
      query = <<-QUERY
{
  how_long_do_you_need_the_space: custom_attribute_definition(name: "how_long_do_you_need_the_space"){ valid_values }
  how_often_will_you_be_visiting: custom_attribute_definition(name: "how_often_will_you_be_visiting"){ valid_values }
  what_will_you_be_storing: custom_attribute_definition(name: "what_will_you_be_storing"){ valid_values }
}
      QUERY

      i.graph_queries.create!(
        name: 'reservation_custom_attributes',
        query_string: query
      )
    end
  end

  def down
    Instances::InstanceFinder.get(:spacercom, :spacerau).each do |i|
      i.set_context!
      i.graph_queries.where(name: 'reservation_custom_attributes').delete_all
    end
  end
end
