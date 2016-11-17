# frozen_string_literal: true
class PaginatingDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_entries, :total_pages, :total_count, :per_page, :offset, :next_page, to: :object
end
