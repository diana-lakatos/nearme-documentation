Given 'the Sphinx indexes are updated' do
  # Update all indexes
  ThinkingSphinx::Test.index
  sleep(0.25) # Wait for Sphinx to catch up
end

Given 'the Sphinx indexes for listings are updated' do
  ThinkingSphinx::Test.index 'listings_core'
  sleep(0.25) # Wait for Sphinx to catch up
end