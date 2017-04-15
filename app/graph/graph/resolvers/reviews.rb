# frozen_string_literal: true
module Graph
  module Resolvers
    class Reviews
      def call(user, _arguments, _ctx)
        @user_id = user.id
        reviews_about_seller
      end

      private

      def reviews_about_seller
        Review.about_seller(@user_id)
      end
    end
  end
end
