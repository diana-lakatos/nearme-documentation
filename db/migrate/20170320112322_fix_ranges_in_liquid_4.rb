class FixRangesInLiquid4 < ActiveRecord::Migration
  REPLACES = [
    [
      '{% for i in (1..stars_count) %}',
      '{% assign stars_count_rounded = stars_count | round %}
       {% for i in (1..stars_count_rounded) %}'
    ],
    [
      '{% for i in (stars_count..4) %}',
      '{% assign stars_count_rounded = stars_count | round %}
       {% for i in (stars_count_rounded..4) %}'
    ],
    [
      '{% for i in (1..stars) %}',
      '{% assign stars_rounded = stars | round %}
       {% for i in (1..stars_rounded) %}'
    ],
    [
      '{% for i in (stars..4) %}',
      '{% assign stars_rounded = stars | round %}
      {% for i in (stars_rounded..4) %}'
    ],
    [
      '{% for i in (1..listing.average_rating) %}',
      '{% assign average_rating_rounded = listing.average_rating | round %}
       {% for i in (1..average_rating_rounded) %}'
    ],
    [
      '{% for i in (listing.average_rating..4) %}',
      '{% assign average_rating_rounded = listing.average_rating | round %}
       {% for i in (average_rating_rounded..4) %}'
    ],
    [
      '{% for i in (1..listing.creator.seller_average_rating) %}',
      '{% assign seller_average_rating_rounded = listing.creator.seller_average_rating | round %}
       {% for i in (1..seller_average_rating_rounded) %}'
    ],
    [
      '{% for i in (listing.creator.seller_average_rating..4) %}',
      '{% assign seller_average_rating_rounded = listing.creator.seller_average_rating | round %}
       {% for i in (seller_average_rating_rounded..4) %}'
    ]
  ]

  def escape(string)
    string.gsub('%', '\%')
  end

  def up
    puts 'Updating ranges in liquid'
    REPLACES.each do |(old, updated)|
      puts "Updating #{old}"
      InstanceView.where('body like ?', "%#{escape(old)}%").find_each do |iv|
        puts "Updating view: #{iv.path} #{iv.id}"
        iv.update_column(:body, iv.body.gsub(old, updated))
      end
    end
  end

  def down
    REPLACES.each do |(old, updated)|
      InstanceView.where('body like ?', "%#{escape(updated)}%").find_each do |iv|
        iv.update_column(:body, iv.body.gsub(updated, old))
      end
    end
  end
end
