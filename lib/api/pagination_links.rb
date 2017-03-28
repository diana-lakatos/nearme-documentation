# frozen_string_literal: true
module Api
  class PaginationLinks
    attr_reader :total_pages

    def initialize(url_generator, total_pages, params)
      @url_generator = url_generator
      @total_pages = total_pages
      @params = params
    end

    def self.links(url_generator:, total_pages:, current_page:, params:)
      pagination = new(url_generator, total_pages, params)
      {
        first: pagination.first,
        last: pagination.last,
        prev: pagination.prev(current_page),
        next: pagination.next(current_page)
      }
    end

    def first
      generate_url_for_page(1)
    end

    def last
      generate_url_for_page(total_pages)
    end

    def prev(current_page)
      current_page > 1 ? generate_url_for_page(current_page - 1) : nil
    end

    def next(current_page)
      current_page < total_pages ? generate_url_for_page(current_page + 1) : nil
    end

    private

    def generate_url_for_page(page)
      @url_generator.call(@params.merge(page: page))
    end
  end
end
