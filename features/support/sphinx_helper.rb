module SphinxHelper
  def update_listings_indexes
    ThinkingSphinx::Test.index 'listings_core'
    wait_for_sphinx_to_catch_up
  end

  def update_all_indexes
    ThinkingSphinx::Test.index
    wait_for_sphinx_to_catch_up
  end

  def wait_for_sphinx_to_catch_up
    sleep(0.25)
  end
end
World(SphinxHelper)
