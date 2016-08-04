class TransferTaggingsByUserdecoratorToUser < ActiveRecord::Migration
  def up
    # We dont want to use the fast SQL update_all as we want to use validations during update
    Tagging.where(tagger_type: 'UserDecorator').map{ |tagging| tagging.update_attributes(tagger_type: 'User') }
    # If taggings exist for User and UserDecorator, they will stay in DB because of the validations (uniqueness).
    # Then we remove the junk:
    Tagging.where(tagger_type: 'UserDecorator').destroy_all
  end

  def down; end
end
