class SearcherDrop < BaseDrop
	delegate :query, :input_value, :category_ids, :categories, :category_options, 
		:keyword, :located, :offset, :min_price, :current_min_price, :current_max_price, 
		:transactable_type, to: :searcher

	def initialize(searcher)
		@searcher = searcher
	end

	def results
		@searcher.results.map(&:to_liquid)
	end
end
