module ElasticIndexer
  class ReviewAggregatorSerializer < ActiveModel::Serializer
    self.root = false

    attributes :total,
               :about_seller,
               :about_buyer,
               :left_by_seller,
               :left_by_buyer,
               :left_by_buyer_about_host,
               :left_by_buyer_about_transactable
  end
end
