require 'test_helper'

class TaxonTest < ActionView::TestCase
  context 'saving' do
    should 'should create permalink after save and update' do
      @taxon = FactoryGirl.build(:taxons)
      assert_nil @taxon.permalink
      @taxon.save
      assert_equal @taxon.permalink, @taxon.name.to_url
      @taxon.name = "New name"
      @taxon.save
      assert_equal @taxon.permalink, 'new-name'
    end

    should 'should update children permalink after parent save' do
      @parent_taxon = FactoryGirl.create(:taxons)
      @children_taxon = FactoryGirl.create(:taxons, parent_id: @parent_taxon.id)
      assert_equal @children_taxon.permalink, [@parent_taxon.permalink, @children_taxon.name].join("/")
      @parent_taxon.name = "New name"
      @parent_taxon.save
      assert_equal @children_taxon.reload.permalink, ['new-name', @children_taxon.name].join("/")
    end
  end
end

