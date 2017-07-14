# frozen_string_literal: true
module Pages
  class PageQuery
    def initialize(slug:, slug2: nil, slug3: nil, relation: Page.all, format: Page::DEFAULT_FORMAT)
      @relation = relation
      @slug = slug
      @slug2 = slug2
      @slug3 = slug3
      @format = format || Page::DEFAULT_FORMAT
    end

    def find
      page = array_combination([@slug, @slug2, @slug3])
             .map { |slugs| slugs.compact.join('/') }
             .lazy
             .map { |slugs| pages.find_by(slug: slugs) }
             .find(&:present?)

      filter(page)
    end

    private

    def pages
      @pages ||= @relation.where(format: Page.formats.fetch(@format, nil))
    end

    def filter(page)
      raise Page::NotFound unless page.present?
      raise Page::NotFound if page.max_deep_level < 2 && @slug2.present?
      raise Page::NotFound if page.max_deep_level < 3 && @slug3.present?

      page
    end

    # @return [Array<Array<Object>>] [[1, 2, 3], [1, 2], [1]]
    # @param array [Array<Object>] [1, 2, 3]
    def array_combination(array)
      array.reverse.each_with_object([]) do |item, memo|
        memo << []
        memo.each { |m| m.unshift item }
      end
    end
  end
end
